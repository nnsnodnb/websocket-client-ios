//
//  BundleClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/24.
//

import ComposableArchitecture
import Foundation

@DependencyClient
public struct BundleClient: Sendable {
  public var shortVersionString: @Sendable () -> String = { "" }
  public var formAboveBannerADUnitID: @Sendable () -> String = { "" }
  public var webSocketConnectionRewardInterstitialAdUnitID: @Sendable () -> String = { "" }
}

// MARK: - DependencyKey
extension BundleClient: DependencyKey {
  public static let liveValue: Self = .init(
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
