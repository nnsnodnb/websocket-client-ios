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
    case formAboveBannerAdUnitID = "FORM_ABOVE_BANNER_AD_UNIT_ID"
  }
}
