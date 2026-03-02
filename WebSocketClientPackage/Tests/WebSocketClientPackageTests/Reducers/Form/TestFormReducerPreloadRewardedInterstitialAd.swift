//
//  TestFormReducerPreloadRewardedInterstitialAd.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestFormReducerPreloadRewardedInterstitialAd {
  @Test(
    .dependencies {
      $0.rewardInterstitialAd.load = {}
    }
  )
  func testIt() async throws {
    let store = TestStore(
      initialState: FormReducer.State(),
      reducer: {
        FormReducer()
      },
    )

    await store.send(.preloadRewardedInterstitialAd)
  }
}
