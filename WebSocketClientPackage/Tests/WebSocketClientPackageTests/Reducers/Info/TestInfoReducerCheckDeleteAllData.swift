//
//  TestInfoReducerCheckDeleteAllData.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/04/28.
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestInfoReducerCheckDeleteAllData {
  @Test
  func testCheckDeleteAllData() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.checkDeleteAllData) {
      $0.alert = AlertState(
        title: {
          TextState(.infoAlertConfirmTitleMessage)
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
            action: .send(.deleteAllData),
            label: {
              TextState(.alertButtonTitleDelete)
            }
          )
        }
      )
    }
  }
}
