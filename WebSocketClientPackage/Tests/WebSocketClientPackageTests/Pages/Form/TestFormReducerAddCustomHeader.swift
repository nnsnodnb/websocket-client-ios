//
//  TestFormReducerAddCustomHeader.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestFormReducerAddCustomHeader {
  @Test(.dependency(\.uuid, .incrementing))
  func testAddCustomHeader() async {
    let store = TestStore(
      initialState: FormReducer.State(),
      reducer: {
        FormReducer()
      },
    )

    await store.send(.addCustomHeader) {
      $0.customHeaders = [
        .init(id: .init(0))
      ]
    }

    await store.send(.addCustomHeader) {
      $0.customHeaders = [
        .init(id: .init(0)),
        .init(id: .init(1))
      ]
    }
  }
}
