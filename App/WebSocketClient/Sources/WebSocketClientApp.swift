//
//  WebSocketClientApp.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import SwiftUI
import WebSocketClientPackage
import XCTestDynamicOverlay

@main
struct WebSocketClientApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                RootPage(
                    store: Store(initialState: RootReducer.State()) {
                        RootReducer()
                    }
                )
            }
        }
    }
}
