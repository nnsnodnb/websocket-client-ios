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
        RootPage(
          store: Store(
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
