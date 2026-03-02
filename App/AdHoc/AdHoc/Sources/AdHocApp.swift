//
//  AdHocApp.swift
//  AdHoc
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import Dependencies
import FirebaseCore
import GoogleMobileAds
import SwiftData
import SwiftUI
import WebSocketClientPackage

@main
struct AdHocApp: App {
  // MARK: - Dependency
  @Dependency(\.bundle)
  private var bundle
  @Dependency(\.modelContext.make)
  private var modelContext

  // MARK: - Body
  var body: some Scene {
    WindowGroup {
      RootPage(
        store: .init(
          initialState: RootReducer.State(
            migratedToSwiftData: UserDefaults.standard.bool(forKey: "key_migrated_to_swift_data"),
          ),
          reducer: {
            RootReducer()
          },
          withDependencies: {
            $0.adUnitID.formAboveBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
            $0.adUnitID.webSocketConnectionRewardInterstitialAdUnitID = { "ca-app-pub-3940256099942544/6978759866" }
          },
        )
      )
      .modelContext(modelContext())
    }
  }

  // MARK: - Initialize
  init() {
    FirebaseApp.configure()
    Task {
      _ = await MobileAds.shared.start()
      MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
        "d174e9a2371e6297c61a872fb5fa9d6a",
      ]
    }
  }
}
