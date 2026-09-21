//
//  RewardInterstitialAdClient.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct RewardInterstitialAdClient: Sendable {
  public var load: @Sendable () async throws -> Void
  public var show: @Sendable () async throws -> Int
}

// MARK: - DependencyKey
extension RewardInterstitialAdClient: DependencyKey {
  public static let liveValue: RewardInterstitialAdClient = .init(
    load: {},
    show: { 0 },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var rewardInterstitialAd: RewardInterstitialAdClient {
    get {
      self[RewardInterstitialAdClient.self]
    }
    set {
      self[RewardInterstitialAdClient.self] = newValue
    }
  }
}
