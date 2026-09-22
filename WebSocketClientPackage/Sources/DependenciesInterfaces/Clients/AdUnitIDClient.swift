//
//  AdUnitIDClient.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/21.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AdUnitIDClient: Sendable {
  // MARK: - Properties
  public var formAboveBannerAdUnitID: @Sendable () throws -> String
  // swiftlint:disable:next identifier_name
  public var webSocketConnectionRewardInterstitialAdUnitID: @Sendable () throws -> String
}

// MARK: - DependencyKey
extension AdUnitIDClient: DependencyKey {
  public static let liveValue: Self = .init()
  public static let previewValue: Self = .init(
    formAboveBannerAdUnitID: { "ca-app-pub-3940256099942544/2435281174" },
    webSocketConnectionRewardInterstitialAdUnitID: { "ca-app-pub-3940256099942544/6978759866" },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var adUnitID: AdUnitIDClient {
    get {
      self[AdUnitIDClient.self]
    }
    set {
      self[AdUnitIDClient.self] = newValue
    }
  }
}
