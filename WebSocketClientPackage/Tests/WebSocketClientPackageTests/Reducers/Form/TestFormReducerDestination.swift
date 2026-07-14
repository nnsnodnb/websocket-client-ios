//
//  TestFormReducerDestination.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestFormReducerDestination {
  @Test
  func testPresentedAlertWatchEarnedReward() async {
    let now = Date()

    await withDependencies {
      $0.date = .constant(now)
      $0.rewardInterstitialAd.load = {}
      $0.rewardInterstitialAd.show = { 1 }
      $0.uuid = .incrementing
    } operation: {
      let url = URL(string: "wss://echo.websocket.org")!

      let store = TestStore(
        initialState: FormReducer.State(
          adUnitID: "ca-app-pub-3940256099942544/2435281174",
          url: url,
          isConnectButtonDisable: false,
          destination: .alert(
            .init(
              title: {
                TextState(.formAlertWatchTitle)
              },
              actions: {
                ButtonState(
                  role: .cancel,
                  label: {
                    TextState(.alertButtonTitleCancel)
                  },
                )
                ButtonState(
                  action: .watch(url),
                  label: {
                    TextState(.formAlertWatchTitleContinue)
                  },
                )
              },
            )
          )
        ),
        reducer: {
          FormReducer()
        },
      )

      await store.send(.destination(.presented(.alert(.watch(url))))) {
        $0.destination = nil
      }
      await store.receive(\.connect, URL(string: "wss://echo.websocket.org")!) {
        let history = HistoryEntity(
          id: .init(0),
          url: URL(string: "wss://echo.websocket.org")!,
          customHeaders: [],
          messages: [],
          isConnectionSuccess: false,
          createdAt: now,
        )
        $0.destination = .connection(
          .init(
            url: URL(string: "wss://echo.websocket.org")!,
            history: history
          )
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
  func testPresentedAlertWatchNotEarnedReward() async {
    let url = URL(string: "wss://echo.websocket.org")!

    let store = TestStore(
      initialState: FormReducer.State(
        adUnitID: "ca-app-pub-3940256099942544/2435281174",
        url: url,
        isConnectButtonDisable: false,
        destination: .alert(
          .init(
            title: {
              TextState(.formAlertWatchTitle)
            },
            actions: {
              ButtonState(
                role: .cancel,
                label: {
                  TextState(.alertButtonTitleCancel)
                },
              )
              ButtonState(
                action: .watch(url),
                label: {
                  TextState(.formAlertWatchTitleContinue)
                },
              )
            },
          )
        )
      ),
      reducer: {
        FormReducer()
      },
    )

    await store.send(.destination(.presented(.alert(.watch(url))))) {
      $0.destination = nil
    }
    await store.receive(\.preloadRewardedInterstitialAd)
  }
}
