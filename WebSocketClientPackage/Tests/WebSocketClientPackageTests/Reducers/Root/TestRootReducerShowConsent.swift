//
//  TestRootReducerShowConsent.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestRootReducerShowConsent {
  @Test
  func testShowConsentDidMigrateToSwiftData() async throws {
    let store = TestStore(
      initialState: RootReducer.State(
        migratedToSwiftData: true,
      ),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.showConsent)
  }

  @Test
  func testShowConsentDidNotMigrateToSwiftData() async throws {
    let store = TestStore(
      initialState: RootReducer.State(
        migratedToSwiftData: false,
      ),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.showConsent) {
      $0.migratedToSwiftData = true
    }
  }
}
