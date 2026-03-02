//
//  TestFormReducerURLChanged.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import Foundation
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestFormReducerURLChanged {
  func testURLChanged() async {
    let store = TestStore(
      initialState: FormReducer.State(),
      reducer: {
        FormReducer()
      },
    )

    await store.send(.urlChanged("wss://echo.websocket.org")) {
      $0.url = URL(string: "wss://echo.websocket.org")
      $0.customHeaders = []
      $0.isConnectButtonDisable = false
    }
  }
}
