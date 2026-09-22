//
//  BundleClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/24.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct BundleClient: Sendable {
  public var shortVersionString: @Sendable () -> String = { "" }
  public var formAboveBannerADUnitID: @Sendable () -> String = { "" }
  // swiftlint:disable:next identifier_name
  public var webSocketConnectionRewardInterstitialAdUnitID: @Sendable () -> String = { "" }
}

// MARK: - DependencyKey
extension BundleClient: DependencyKey {
  public static let liveValue: Self = .init(
    shortVersionString: { "1.0.0-live" },
    formAboveBannerADUnitID: { "form_above_banner_ad_unit_id" },
    webSocketConnectionRewardInterstitialAdUnitID: { "web_socket_connection_reward_interstitial_ad_unit_id" },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var bundle: BundleClient {
    get {
      self[BundleClient.self]
    }
    set {
      self[BundleClient.self] = newValue
    }
  }
}
