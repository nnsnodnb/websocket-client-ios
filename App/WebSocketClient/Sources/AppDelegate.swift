//
//  AppDelegate.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import FirebaseCore
import GoogleMobileAds
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    Task {
      _ = await MobileAds.shared.start()
      MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
        "d174e9a2371e6297c61a872fb5fa9d6a",
      ]
    }
    return true
  }
}
