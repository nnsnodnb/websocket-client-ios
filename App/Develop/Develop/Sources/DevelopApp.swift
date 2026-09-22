//
//  DevelopApp.swift
//  Develop
//
//  Created by Yuya Oka on 2026/03/02.
//

import ComposableArchitecture
import Dependencies
import DependenciesInterfaces
import DependenciesLive
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseCore
import GoogleMobileAds
import SwiftData
import SwiftUI
import WebSocketClientPackage
import IssueReporting

@main
struct DevelopApp: App {
  // MARK: - Dependency
  @Dependency(\.bundle)
  private var bundle
  @Dependency(\.modelContext.make)
  private var modelContext

  // MARK: - Body
  var body: some Scene {
    WindowGroup {
      if !isTesting {
        prepareDependencies {
          $0.adClient = .google
          $0.adUnitID = .debug
          $0.analytics = .firebase
          $0.bundle = .bundle
          $0.consentInformation = .google
          $0.rewardInterstitialAd = .google
          $0.webSocket = .urlSession

          return RootPage(
            store: .init(
              initialState: RootReducer.State(
                migratedToSwiftData: UserDefaults.standard.bool(forKey: "key_migrated_to_swift_data"),
              ),
              reducer: {
                RootReducer()
              },
            )
          )
          .modelContext(modelContext())
        }
      }
    }
  }

  // MARK: - Initialize
  init() {
    FirebaseApp.configure()
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    Task {
      _ = await MobileAds.shared.start()
      MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
        "d174e9a2371e6297c61a872fb5fa9d6a",
      ]
    }
  }
}
