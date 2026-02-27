//
//  AppIconListReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/04.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import WebSocketClientPackage
import Testing

@MainActor
struct AppIconListReducerTests {
  @Test(
    .dependencies {
      $0.application.setAlternateIconName = { _ in }
    }
  )
  func testAppIconChanged() async throws {
    let store = TestStore(
      initialState: AppIconListReducer.State(),
      reducer: {
        AppIconListReducer()
      }
    )

    // default
    await store.send(.appIconChanged(.default))
    await store.receive(\.setAlternateIconNameResponse)

    // yellow
    await store.send(.appIconChanged(.yellow))
    await store.receive(\.setAlternateIconNameResponse)

    // red
    await store.send(.appIconChanged(.red))
    await store.receive(\.setAlternateIconNameResponse)

    // blue
    await store.send(.appIconChanged(.blue))
    await store.receive(\.setAlternateIconNameResponse)

    // purple
    await store.send(.appIconChanged(.purple))
    await store.receive(\.setAlternateIconNameResponse)

    // black
    await store.send(.appIconChanged(.black))
    await store.receive(\.setAlternateIconNameResponse)

    // white
    await store.send(.appIconChanged(.white))
    await store.receive(\.setAlternateIconNameResponse)
  }
}
