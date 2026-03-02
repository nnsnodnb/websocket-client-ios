//
//  TestInfoReducerURLSelected.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
import Foundation
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestInfoReducerURLSelected {
  @Test
  func testIt() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.urlSelected(URL(string: "https://github.com/nnsnodnb/websocket-client-ios")!)) {
      $0.url = URL(string: "https://github.com/nnsnodnb/websocket-client-ios")
    }
    await store.send(.urlSelected(nil)) {
      $0.url = nil
    }
  }
}
