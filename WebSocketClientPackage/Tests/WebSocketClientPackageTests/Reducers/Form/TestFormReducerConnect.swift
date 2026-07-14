//
//  TestFormReducerConnect.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestFormReducerConnect {
  @Test
  func testConnect() async {
    let now = Date()

    await withDependencies {
      $0.uuid = .incrementing
      $0.date = .constant(now)
    } operation: {
      let store = TestStore(
        initialState: FormReducer.State(
          url: URL(string: "wss://echo.websocket.org"),
          isConnectButtonDisable: false,
        ),
        reducer: {
          FormReducer()
        },
      )

      await store.send(.connect(URL(string: "wss://echo.websocket.org")!)) {
        let history = HistoryEntity(
          id: .init(0),
          url: URL(string: "wss://echo.websocket.org")!,
          customHeaders: [],
          messages: [],
          isConnectionSuccess: false,
          createdAt: now,
        )
        $0.destination = .connection(
          .init(
            url: URL(string: "wss://echo.websocket.org")!,
            history: history
          )
        )
      }
    }
  }
}
