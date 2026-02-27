//
//  WebSocketClientApp.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import Dependencies
import SwiftData
import SwiftUI
import WebSocketClientPackage
import XCTestDynamicOverlay

@main
struct WebSocketClientApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate

  @Dependency(\.modelContext.make)
  private var modelContext

  var body: some Scene {
    WindowGroup {
      if !_XCTIsTesting {
#if RELEASE
        RootPage(
          store: .init(
            initialState: RootReducer.State(
              formAboveBannerAdUnitID: "ca-app-pub-3417597686353524/4750338458",
              migratedToSwiftData: UserDefaults.standard.bool(forKey: "key_migrated_to_swift_data")
            ),
            reducer: {
              RootReducer()
            },
          )
        )
        .modelContext(modelContext())
#else
        RootPage(
          store: Store(
            initialState: RootReducer.State(
              formAboveBannerAdUnitID: "ca-app-pub-3940256099942544/2435281174",
              migratedToSwiftData: UserDefaults.standard.bool(forKey: "key_migrated_to_swift_data"),
            ),
            reducer: {
              RootReducer()
            },
          )
        )
        .modelContext(modelContext())
#endif
      }
    }
  }
}
