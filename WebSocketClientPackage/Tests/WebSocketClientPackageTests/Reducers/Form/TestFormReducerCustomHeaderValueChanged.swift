//
//  TestFormReducerCustomHeaderValueChanged.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/04/16.
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestFormReducerCustomHeaderValueChanged {
  @Test(.dependency(\.uuid, .incrementing))
  func testCustomHeaderValueChanged() async {
    let store = TestStore(
      initialState: FormReducer.State(
        customHeaders: [
          .init(id: .init(0))
        ],
      ),
      reducer: {
        FormReducer()
      },
    )

    await store.send(.customHeaderValueChanged(0, "application/json")) {
      var customHeader = CustomHeaderEntity(id: .init(0))
      customHeader.setValue("application/json")
      $0.customHeaders = [
        customHeader
      ]
    }
  }
}
