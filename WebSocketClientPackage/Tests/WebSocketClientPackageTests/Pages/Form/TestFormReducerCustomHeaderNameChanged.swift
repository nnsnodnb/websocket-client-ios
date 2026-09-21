//
//  Test.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import DependenciesTestSupport
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestFormReducerCustomHeaderNameChanged {
  @Test(.dependency(\.uuid, .incrementing))
  func testCustomHeaderNameChanged() async {
    let store = TestStore(
      initialState: FormReducer.State(
        customHeaders: [
          .init(id: .init(0)),
        ],
      ),
      reducer: {
        FormReducer()
      },
    )

    await store.send(.customHeaderNameChanged(0, "Authorization")) {
      var customHeader = CustomHeaderEntity(id: .init(0))
      customHeader.setName("Authorization")
      $0.customHeaders = [
        customHeader
      ]
    }
  }
}
