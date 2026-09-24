//
//  TestHistoryDetailReducerShowedCustomHeaderList.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestHistoryDetailReducerShowedCustomHeaderList {
  @Test
  func testShowCustomHeaderList() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )

    let store = TestStore(
      initialState: HistoryDetailReducer.State(
        history: history,
      ),
      reducer: {
        HistoryDetailReducer()
      },
    )

    await store.send(.showedCustomHeaderList(true)) {
      $0.isShowCustomHeaderList = true
    }
  }

  @Test
  func testDismissCustomHeaderList() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )

    let store = TestStore(
      initialState: HistoryDetailReducer.State(
        history: history,
        isShowCustomHeaderList: true,
      ),
      reducer: {
        HistoryDetailReducer()
      },
    )

    await store.send(.showedCustomHeaderList(false)) {
      $0.isShowCustomHeaderList = false
    }
  }
}
