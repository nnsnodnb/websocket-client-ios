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
public struct WebSocketClient: Sendable {
    // MARK: - ID
    public struct CancelID: Hashable, @unchecked Sendable {
        // MARK: - Properties
        public let rawValue: AnyHashableSendable

        // MARK: - Initialize
        init<RawValue: Hashable & Sendable>(_ rawValue: RawValue) {
            self.rawValue = .init(rawValue)
        }

        public init() {
            struct RawValue: Hashable, Sendable {
            }
            self.rawValue = .init(RawValue())
        }
    }

    // MARK: - Action
    @CasePathable
    public enum Action: Sendable, Equatable {
        case didOpen(protocol: String?)
        case didClose(code: URLSessionWebSocketTask.CloseCode, reason: Data?)
    }

    // MARK: - Message
    @CasePathable
    public enum Message: Sendable, Equatable {
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
    public var open: @Sendable (CancelID, URLRequest) async throws -> AsyncStream<Action>
    public var receive: @Sendable (CancelID) async throws -> AsyncStream<Result<Message, Error>>
    public var send: @Sendable (CancelID, URLSessionWebSocketTask.Message) async throws -> Void
    public var sendPing: @Sendable (CancelID) async throws -> Void
}

// MARK: - WebSocketActor
public extension WebSocketClient {
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
        }

        // MARK: - Dependencies
        typealias Dependencies = (socket: URLSessionWebSocketTask, delegate: Delegate)

        // MARK: - Properties
        public static let shared = WebSocketActor()

        var dependencies: [CancelID: Dependencies] = [:]

        func open(id: CancelID, urlRequest: URLRequest) -> AsyncStream<Action> {
            let delegate = Delegate()
            let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
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

// MARK: - DependencyKey
extension WebSocketClient: DependencyKey {
    public static let liveValue: Self = .init(
        open: { await WebSocketActor.shared.open(id: $0, urlRequest: $1) },
        receive: { try await WebSocketActor.shared.receive(id: $0) },
        send: { try await WebSocketActor.shared.send(id: $0, message: $1) },
        sendPing: { try await WebSocketActor.shared.sendPing(id: $0) }
    )
}

// MARK: - DependencyValues
public extension DependencyValues {
    var webSocket: WebSocketClient {
        get {
            self[WebSocketClient.self]
        }
        set {
            self[WebSocketClient.self] = newValue
        }
    }
}
