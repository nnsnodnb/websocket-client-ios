//
//  TestAppIconListReducerAppIconChanged.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/04.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestAppIconListReducerAppIconChanged {
  @Test(arguments: AppIconListReducer.State.AppIcon.allCases)
  func testAppIconChanged(appIcon: AppIconListReducer.State.AppIcon) async throws {
    await withDependencies {
      $0.application.setAlternateIconName = { _ in }
    } operation: {
      let store = TestStore(
        initialState: AppIconListReducer.State(),
        reducer: {
          AppIconListReducer()
        }
      )

      // default
      await store.send(.appIconChanged(appIcon))
      await store.receive(\.setAlternateIconNameResponse)
    }
  }
}
