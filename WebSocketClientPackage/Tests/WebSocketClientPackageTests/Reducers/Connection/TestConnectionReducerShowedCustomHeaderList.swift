//
//  TestConnectionReducerShowedCustomHeaderList.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/28.
//

import ComposableArchitecture
import Foundation
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestConnectionReducerShowedCustomHeaderList {
  @Test
  func testShow() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: false,
      createdAt: .init()
    )
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
  func testHide() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: false,
      createdAt: .init()
    )
    let store = TestStore(
      initialState: ConnectionReducer.State(
        url: URL(string: "wss://echo.websocket.org")!,
        history: history,
        isShowCustomHeaderList: true,
      ),
      reducer: {
        ConnectionReducer()
      },
    )

    await store.send(.showedCustomHeaderList(false)) {
      $0.isShowCustomHeaderList = false
    }
  }
}
