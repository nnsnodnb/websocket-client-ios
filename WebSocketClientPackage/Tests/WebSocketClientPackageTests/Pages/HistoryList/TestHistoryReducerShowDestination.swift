//
//  TestHistoryReducerShowDestination.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/24.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestHistoryReducerShowDestination {
  @Test
  func testSetHistory() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )

    let store = TestStore(
      initialState: HistoryListReducer.State(
        histories: .init(uniqueElements: [history]),
      ),
      reducer: {
        HistoryListReducer()
      },
    )

    await store.send(.showDestination(.historyDetail(history))) {
      $0.historyDetail = .init(history: history)
    }
  }

  @Test
  func testSetNil() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )

    let store = TestStore(
      initialState: HistoryListReducer.State(
        histories: .init(uniqueElements: [history]),
        historyDetail: .init(history: history),
      ),
      reducer: {
        HistoryListReducer()
      },
    )

    await store.send(.showDestination(nil)) {
      $0.historyDetail = nil
    }
  }
}
