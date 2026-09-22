//
//  WebSocketClient+Extension.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/22.
//

import ConcurrencyExtras
import DependenciesInterfaces
import Foundation

public extension WebSocketClient {
  static let urlSession: Self = .init(
    open: { await WebSocketActor.shared.open(id: $0, urlRequest: $1) },
    close: { try await WebSocketActor.shared.close(id: $0, with: .normalClosure, reason: nil) },
    receive: { try await WebSocketActor.shared.receive(id: $0) },
    send: { try await WebSocketActor.shared.send(id: $0, message: $1) },
    sendPing: { try await WebSocketActor.shared.sendPing(id: $0) }
  )
}

// MARK: - WebSocketActor
private extension WebSocketClient {
  final actor WebSocketActor: GlobalActor {
    // MARK: - Delegate
    public final class Delegate: NSObject, URLSessionWebSocketDelegate {
      // MARK: - Properties
      let continuation: LockIsolated<AsyncStream<Action>.Continuation?> = .init(nil)

      // MARK: - URLSessionWebSocketDelegate
      public func urlSession(
        _: URLSession,
        webSocketTask _: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
      ) {
        continuation.withValue { continuation in
          _ = continuation?.yield(.didOpen(protocol: `protocol`))
        }
      }

      public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
      ) {
        continuation.withValue { continuation in
          continuation?.yield(.didClose(code: closeCode, reason: reason))
          continuation?.finish()
        }
      }

      public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        // error == nilの場合は、urlSession(_:webSocketTask:didCloseWith:reason:)に流れてくる方を信用する
        guard error != nil else { return }
        continuation.withValue { continuation in
          continuation?.yield(.didClose(code: .abnormalClosure, reason: nil))
          continuation?.finish()
        }
      }
    }

    // MARK: - Dependencies
    typealias Dependencies = (socket: URLSessionWebSocketTask, delegate: Delegate)

    // MARK: - Properties
    static let shared = WebSocketActor()

    var dependencies: [CancelID: Dependencies] = [:]

    func open(id: CancelID, urlRequest: URLRequest) -> AsyncStream<Action> {
      let delegate = Delegate()
      let configuration = URLSessionConfiguration.ephemeral
      configuration.timeoutIntervalForRequest = 10
      let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)

      let socket = session.webSocketTask(with: urlRequest)
      defer { socket.resume() }
      let stream = AsyncStream<Action> { continuation in
        continuation.onTermination = { _ in
          socket.cancel()
          Task {
            await self.removeDependencies(id: id)
          }
        }
        delegate.continuation.setValue(continuation)
      }
      dependencies[id] = (socket, delegate)
      return stream
    }

    func close(
      id: CancelID,
      with closeCode: URLSessionWebSocketTask.CloseCode,
      reason: Data?
    ) async throws {
      defer { dependencies[id] = nil }
      try socket(id: id).cancel(with: closeCode, reason: reason)
    }

    func receive(id: CancelID) throws -> AsyncStream<Result<Message, Error>> {
      let socket = try self.socket(id: id)
      return AsyncStream { continuation in
        let task = Task {
          while !Task.isCancelled {
            continuation.yield(
              await Result(
                catching: {
                  try await Message(socket.receive())
                }
              )
            )
          }
          continuation.finish()
        }
        continuation.onTermination = { _ in
          task.cancel()
        }
      }
    }

    func send(id: CancelID, message: URLSessionWebSocketTask.Message) async throws {
      try await socket(id: id).send(message)
    }

    func sendPing(id: CancelID) async throws {
      let socket = try socket(id: id)
      Logger.debug("Ping WebSocket")
      return try await withCheckedThrowingContinuation { continuation in
        socket.sendPing { error in
          if let error {
            continuation.resume(throwing: error)
            Logger.error("Failed ping: \(error)")
          } else {
            continuation.resume()
            Logger.debug("Pong WebSocket")
          }
        }
      }
    }

    private func socket(id: CancelID) throws -> URLSessionWebSocketTask {
      guard let dependencies = dependencies[id]?.socket else {
        struct Closed: Error {}
        throw Closed()
      }
      return dependencies
    }

    private func removeDependencies(id: CancelID) {
      dependencies[id] = nil
    }
  }
}
