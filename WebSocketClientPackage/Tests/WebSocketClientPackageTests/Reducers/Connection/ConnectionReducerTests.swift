//
//  ConnectionReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
import Foundation
@testable import WebSocketClientPackage
import Testing

@MainActor
final class ConnectionReducerTests {
  private var history: HistoryEntity!

  init() {
    self.history = .init(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: false,
      createdAt: .init()
    )
  }

  deinit {
    history = nil
  }

  @Test
  func testShowCustomHeaderList() async throws {
    let store = TestStore(
      initialState: ConnectionReducer.State(
        url: URL(string: "wss://echo.websocket.org")!,
        history: history,
      ),
      reducer: {
        ConnectionReducer()
      },
    )

    // show
    await store.send(.showedCustomHeaderList(true)) {
      $0.isShowCustomHeaderList = true
    }
  }

  @Test
  func testDismissCustomHeaderList() async throws {
    let store = TestStore(
      initialState: ConnectionReducer.State(
        url: URL(string: "wss://echo.websocket.org")!,
        history: history,
      ),
      reducer: {
        ConnectionReducer()
      },
    )

    // already dismiss
    await store.send(.showedCustomHeaderList(false))

    // dismiss
    await store.send(.showedCustomHeaderList(true)) {
      $0.isShowCustomHeaderList = true
    }
    await store.send(.showedCustomHeaderList(false)) {
      $0.isShowCustomHeaderList = false
    }
  }
}
