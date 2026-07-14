//
//  TestInfoReducerBrowserOpen.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestInfoReducerBrowserOpen {
  @Test(
    .dependencies {
      $0.application.canOpenURL = { _ in true }
      $0.application.open = { _ in true }
    }
  )
  func testBrowserOpen() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.browserOpen(URL(string: "https://example.com")!))
    await store.receive(\.browserOpenResponse)
  }
}
