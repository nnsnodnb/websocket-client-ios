//
//  Bundle+Exension.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import Foundation

public extension Bundle {
  var environemnts: [String: Any] {
    Bundle.main.object(forInfoDictionaryKey: "LSEnvironment") as? [String: Any] ?? [:]
  }

  func getEnvironmentValue<T>(_ key: EnvironmentKey) -> T? {
    environemnts[key.rawValue] as? T
  }
}

// MARK: - EnvironmentKey
public extension Bundle {
  enum EnvironmentKey: String {
    // swiftlint:disable identifier_name
    case formAboveBannerAdUnitID = "FORM_ABOVE_BANNER_AD_UNIT_ID"
    case webSocketConnectionRewardInterstitialAdUnitID = "WEBSOCKET_CONNECTION_REWARD_INTERSTITIAL_AD_UNIT_ID"
    // swiftlint:enable identifier_name
  }
}
