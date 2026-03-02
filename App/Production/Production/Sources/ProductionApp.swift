//
//  ProductionApp.swift
//  Production
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
struct ProductionApp: App {
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
            $0.adUnitID.formAboveBannerAdUnitID = { "ca-app-pub-3417597686353524/4750338458" }
            $0.adUnitID.webSocketConnectionRewardInterstitialAdUnitID = { "ca-app-pub-3417597686353524/4189676656" }
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
    }
  }
}
