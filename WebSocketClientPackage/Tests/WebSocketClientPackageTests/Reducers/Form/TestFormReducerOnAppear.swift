//
//  TestFormReducerOnAppear.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestFormReducerOnAppear {
  @Test(
    .dependencies {
      $0.adUnitID.formAboveBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
      $0.rewardInterstitialAd.load = {}
    }
  )
  func testOnAppear() async throws {
    let store = TestStore(
      initialState: FormReducer.State(),
      reducer: {
        FormReducer()
      },
    )

    await store.send(.onAppear) {
      $0.adUnitID = "ca-app-pub-3940256099942544/2435281174"
    }
    await store.receive(\.preloadRewardedInterstitialAd)
  }
}
