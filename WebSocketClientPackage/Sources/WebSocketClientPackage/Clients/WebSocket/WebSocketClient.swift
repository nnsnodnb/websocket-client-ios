//
//  WebSocketClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/18.
//

import CasePaths
import ComposableArchitecture
import Foundation

@DependencyClient
public struct WebSocketClient {
    // MARK: - Action
    @CasePathable
    public enum Action: Equatable {
        case didOpen(protocol: String?)
        case didClose(code: URLSessionWebSocketTask.CloseCode, reason: Data?)
    }

    // MARK: - Message
    @CasePathable
    public enum Message: Equatable {
        case data(Data)
        case string(String)

        // MARK: - Unknown
        public enum Error: Swift.Error {
            case unknown
        }

        // MARK: - Initialize
        public init(_ message: URLSessionWebSocketTask.Message) throws {
            switch message {
            case let .data(data):
                self = .data(data)
            case let .string(string):
                self = .string(string)
            @unknown default:
                throw Error.unknown
            }
        }
    }

    // MARK: - Properties
    public var open: @Sendable (AnyHashable, URLRequest) async throws -> AsyncStream<Action>
    public var receive: @Sendable (AnyHashable) async throws -> AsyncStream<Result<Message, Error>>
    public var send: @Sendable (AnyHashable, URLSessionWebSocketTask.Message) async throws -> Void
    public var sendPing: @Sendable (AnyHashable) async throws -> Void
}

// MARK: - WebSocketActor
public extension WebSocketClient {
    final actor WebSocketActor: GlobalActor {
        // MARK: - Delegate
        public final class Delegate: NSObject, URLSessionWebSocketDelegate {
            // MARK: - Properties
            var continuation: AsyncStream<Action>.Continuation?

            // MARK: - URLSessionWebSocketDelegate
            public func urlSession(
                _: URLSession,
                webSocketTask _: URLSessionWebSocketTask,
                didOpenWithProtocol protocol: String?
            ) {
                continuation?.yield(.didOpen(protocol: `protocol`))
            }

            public func urlSession(
                _ session: URLSession,
                webSocketTask: URLSessionWebSocketTask,
                didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                reason: Data?
            ) {
                continuation?.yield(.didClose(code: closeCode, reason: reason))
                continuation?.finish()
            }
        }

        // MARK: - Dependencies
        typealias Dependencies = (socket: URLSessionWebSocketTask, delegate: Delegate)

        // MARK: - Properties
        public static let shared = WebSocketActor()

        var dependencies: [AnyHashable: Dependencies] = [:]

        func open(id: AnyHashable, urlRequest: URLRequest) -> AsyncStream<Action> {
            let delegate = Delegate()
            let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
            let socket = session.webSocketTask(with: urlRequest)
            defer { socket.resume() }
            var continuation: AsyncStream<Action>.Continuation!
            let stream = AsyncStream<Action> {
                $0.onTermination = { _ in
                    socket.cancel()
                    Task {
                        await self.removeDependencies(id: id)
                    }
                }
                continuation = $0
            }
            delegate.continuation = continuation
            dependencies[id] = (socket, delegate)
            return stream
        }

        func close(
            id: AnyHashable, with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?
        ) async throws {
            defer { dependencies[id] = nil }
            try socket(id: id).cancel(with: closeCode, reason: reason)
        }

        func receive(id: AnyHashable) throws -> AsyncStream<Result<Message, Error>> {
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

        func send(id: AnyHashable, message: URLSessionWebSocketTask.Message) async throws {
            try await socket(id: id).send(message)
        }

        func sendPing(id: AnyHashable) async throws {
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

        private func socket(id: AnyHashable) throws -> URLSessionWebSocketTask {
            guard let dependencies = dependencies[id]?.socket else {
                struct Closed: Error {}
                throw Closed()
            }
            return dependencies
        }

        private func removeDependencies(id: AnyHashable) {
            dependencies[id] = nil
        }
    }
}

// MARK: - DependencyKey
extension WebSocketClient: DependencyKey {
    public static var liveValue: Self {
        return Self(
            open: { await WebSocketActor.shared.open(id: $0, urlRequest: $1) },
            receive: { try await WebSocketActor.shared.receive(id: $0) },
            send: { try await WebSocketActor.shared.send(id: $0, message: $1) },
            sendPing: { try await WebSocketActor.shared.sendPing(id: $0) }
        )
    }

    public static var previewValue: Self = .init()

    public static var testValue: Self = .init()
}
