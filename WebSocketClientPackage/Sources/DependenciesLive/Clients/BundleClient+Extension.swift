//
//  BundleClient+Extension.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/21.
//

import DependenciesInterfaces
import Foundation

public extension BundleClient {
  static let bundle: Self = .init(
    shortVersionString: {
      Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    },
    formAboveBannerADUnitID: {
      Bundle.main.getEnvironmentValue(.formAboveBannerAdUnitID) ?? ""
    },
    webSocketConnectionRewardInterstitialAdUnitID: {
      Bundle.main.getEnvironmentValue(.webSocketConnectionRewardInterstitialAdUnitID) ?? ""
    },
  )
}
