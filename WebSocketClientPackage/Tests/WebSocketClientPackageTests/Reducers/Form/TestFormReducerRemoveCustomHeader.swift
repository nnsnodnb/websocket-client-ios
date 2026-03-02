//
//  TestFormReducerRemoveCustomHeader.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestFormReducerRemoveCustomHeader {
  @Test(.dependency(\.uuid, .incrementing))
  func testRemoveCustomHeader() async {
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

    await store.send(.removeCustomHeader(.init(integer: 0))) {
      $0.customHeaders = []
    }
  }
}
