//
//  WebSocketClient.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/22.
//

import ComposableArchitecture
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct WebSocketClient: Sendable {
  // MARK: - CancelID
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
  public var close: @Sendable (CancelID) async throws -> Void
  public var receive: @Sendable (CancelID) async throws -> AsyncStream<Result<Message, Error>>
  public var send: @Sendable (CancelID, URLSessionWebSocketTask.Message) async throws -> Void
  public var sendPing: @Sendable (CancelID) async throws -> Void
}

// MARK: - DependencyKey
extension WebSocketClient: DependencyKey {
  public static let liveValue: Self = .init(
    open: { _, _ in
      AsyncStream {
        $0.finish()
      }
    },
    close: { _ in },
    receive: { _ in
      AsyncStream {
        $0.finish()
      }
    },
    send: { _, _ in },
    sendPing: { _ in },
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
