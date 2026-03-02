//
//  TestRootReducerConsent.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestRootReducerConsent {
  @Test
  func testDelegateCompletedConsent() async throws {
    let store = TestStore(
      initialState: RootReducer.State(migratedToSwiftData: true),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.consent(.delegate(.completedConsent))) {
      $0.consent = nil
    }
  }
}
