//
//  TestConnectionReducerStart.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/22.
//

import ComposableArchitecture
import ConcurrencyExtras
import Foundation
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestConnectionReducerStart {
  @Test
  func testStart() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: false,
      createdAt: .init()
    )

    await withDependencies {
      $0.continuousClock = .immediate
      $0.database.addHistory = { _ in }
      $0.database.updateHistory = { _ in }
      $0.webSocket.open = { _, _ in
        AsyncStream {
          $0.yield(.didOpen(protocol: "wss"))
        }
      }
    } operation: {
      let store = TestStore(
        initialState: ConnectionReducer.State(
          url: URL(string: "wss://echo.websocket.org")!,
          history: history,
        ),
        reducer: {
          ConnectionReducer()
        },
      )

      await store.send(.start) {
        $0.connectivityState = .connecting
      }
      await store.receive(\.internalAction.addHistoryResponse)
      await store.receive(\.internalAction.webSocket.didOpen, "wss") {
        $0.connectivityState = .connected
        $0.history.successfulConnection()
      }
      await store.receive(\.internalAction.updateHistoryResponse)
      // didOpenでfinishを送っていないのでここではskipする
      await store.skipInFlightEffects()
    }
  }

  @Test
  func testStartConnectivityStateIsConnecting() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: false,
      createdAt: .init()
    )

    await withDependencies {
      $0.database.addHistory = { _ in }
    } operation: {
      let store = TestStore(
        initialState: ConnectionReducer.State(
          url: URL(string: "wss://echo.websocket.org")!,
          connectivityState: .connecting,
          history: history,
        ),
        reducer: {
          ConnectionReducer()
        },
      )

      await store.send(.start)
      await store.receive(\.internalAction.addHistoryResponse)
    }
  }

  @Test
  func testStartConnectedClose() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: false,
      createdAt: .init()
    )
    let calledDismiss: LockIsolated<Bool> = .init(false)

    await withDependencies {
      $0.continuousClock = .immediate
      $0.database.addHistory = { _ in }
      $0.dismiss = .init { calledDismiss.setValue(true) }
      $0.webSocket.open = { _, _ in
        AsyncStream {
          $0.yield(.didOpen(protocol: "wss"))
          $0.yield(.didClose(code: .normalClosure, reason: .init()))
          $0.finish()
        }
      }
    } operation: {
      let store = TestStore(
        initialState: ConnectionReducer.State(
          url: URL(string: "wss://echo.websocket.org")!,
          history: history,
        ),
        reducer: {
          ConnectionReducer()
        },
      )

      await store.send(.start) {
        $0.connectivityState = .connecting
      }
      await store.receive(\.internalAction.addHistoryResponse)
      await store.receive(\.internalAction.webSocket.didOpen, "wss") {
        $0.connectivityState = .connected
        $0.history.successfulConnection()
      }
      await store.receive(\.internalAction.webSocket.didClose) {
        $0.connectivityState = .disconnected
      }
      await store.receive(\.internalAction.updateHistoryResponse)
    }
    #expect(calledDismiss.value)
  }

  @Test
  func testStartConnectingError() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: false,
      createdAt: .init()
    )

    await withDependencies {
      $0.database.addHistory = { _ in }
      $0.webSocket.open = { _, _ in
        AsyncStream {
          $0.yield(.didClose(code: .abnormalClosure, reason: nil))
          $0.finish()
        }
      }
    } operation: {
      let store = TestStore(
        initialState: ConnectionReducer.State(
          url: URL(string: "wss://echo.websocket.org")!,
          history: history,
        ),
        reducer: {
          ConnectionReducer()
        },
      )

      await store.send(.start) {
        $0.connectivityState = .connecting
      }
      await store.receive(\.internalAction.addHistoryResponse)
      await store.receive(\.internalAction.webSocket.didClose) {
        $0.connectivityState = .disconnected
        $0.alert = AlertState(
          title: {
            TextState(.connectionAlertConnectingFailedTitle)
          },
          actions: {
            ButtonState(
              action: .okay,
              label: {
                TextState("OK")
              },
            )
          },
          message: {
            TextState(.connectionAlertConnectingFailedMessage)
          },
        )
      }
    }
  }
}
