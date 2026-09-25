//
//  TestHistoryDetailReducerCheckDelete.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/24.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestHistoryDetailReducerCheckDelete {
  @Test
  func testIt() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )

    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history),
      reducer: {
        HistoryDetailReducer()
      },
    )

    await store.send(.checkDelete) {
      $0.alert = AlertState(
        title: {
          TextState(.historyDetailAlertConfirmTitleMessage)
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState(.alertButtonTitleCancel)
            }
          )
          ButtonState(
            role: .destructive,
            action: .send(.confirm),
            label: {
              TextState(.alertButtonTitleDelete)
            }
          )
        }
      )
    }
  }
}
