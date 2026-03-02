//
//  TestFormReducerOpenAds.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import WebSocketClientPackage
import Foundation
import Testing

@MainActor
struct TestFormReducerOpenAds {
  @Test
  func testOpenAdsEarnedReward() async {
    let now = Date()

    await withDependencies {
      $0.date = .constant(now)
      $0.rewardInterstitialAd.load = {}
      $0.rewardInterstitialAd.show = { 1 }
      $0.uuid = .incrementing
    } operation: {
      let store = TestStore(
        initialState: FormReducer.State(
          adUnitID: "ca-app-pub-3940256099942544/2435281174",
          url: URL(string: "wss://echo.websocket.org"),
          isConnectButtonDisable: false,
        ),
        reducer: {
          FormReducer()
        },
      )

      await store.send(.openAds)
      await store.receive(\.connect, URL(string: "wss://echo.websocket.org")!) {
        let history = HistoryEntity(
          id: .init(0),
          url: URL(string: "wss://echo.websocket.org")!,
          customHeaders: [],
          messages: [],
          isConnectionSuccess: false,
          createdAt: now,
        )
        $0.connection = .init(
          url: URL(string: "wss://echo.websocket.org")!,
          history: history
        )
      }
      await store.receive(\.preloadRewardedInterstitialAd)
    }
  }

  @Test(
    .dependencies {
      $0.rewardInterstitialAd.load = {}
      $0.rewardInterstitialAd.show = { throw RewardInterstitialAdClient.Error.interruption }
    }
  )
  func testOpenAdsNotEarnedReward() async {
    let store = TestStore(
      initialState: FormReducer.State(
        adUnitID: "ca-app-pub-3940256099942544/2435281174",
        url: URL(string: "wss://echo.websocket.org"),
        isConnectButtonDisable: false,
      ),
      reducer: {
        FormReducer()
      },
    )

    await store.send(.openAds)
    await store.receive(\.preloadRewardedInterstitialAd)
  }
}
