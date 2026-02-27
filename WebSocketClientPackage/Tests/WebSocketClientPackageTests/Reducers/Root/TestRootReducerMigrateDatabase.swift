//
//  TestRootReducerMigrateDatabase.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/28.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestRootReducerMigrateDatabase {
  @Test(
    .dependencies {
      $0.database.migrateCoreDataToSwiftData = {}
    }
  )
  func testYetMigrate() async throws {
    let store = TestStore(
      initialState: RootReducer.State(migratedToSwiftData: false),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.migrateDatabase)
    await store.receive(\.migratedDatabase) {
      $0.migratedToSwiftData = true
    }
  }

  @Test
  func testAlreadyMigrated() async throws {
    let store = TestStore(
      initialState: RootReducer.State(migratedToSwiftData: true),
      reducer: {
        RootReducer()
      },
    )

    await store.send(.migrateDatabase)
  }
}
