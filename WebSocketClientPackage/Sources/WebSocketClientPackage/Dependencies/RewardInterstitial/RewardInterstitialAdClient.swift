//
//  RewardInterstitialAdClient.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import Dependencies
import DependenciesMacros
import Foundation
import GoogleMobileAds

@DependencyClient
public struct RewardInterstitialAdClient: Sendable {
  public var load: @Sendable () async throws -> Void
  public var show: @Sendable () async throws -> Int

  // MARK: - Error
  public enum Error: Swift.Error {
    case notReady
    case interruption
  }
}

// MARK: - DependencyKey
extension RewardInterstitialAdClient: DependencyKey {
  public static let liveValue: RewardInterstitialAdClient = .init(
    load: {
      try await Implementation.shared.load()
    },
    show: {
      return try await Implementation.shared.show()
    },
  )
}

// MARK: - Implementation
private extension RewardInterstitialAdClient {
  final actor Implementation: GlobalActor {
    // MARK: - State
    private enum State {
      case idle
      case loading
      case ready(any RewardedInterstitialAdProtocol)
      case failed
    }

    // MARK: - Properties
    static let shared: Implementation = .init()

    private let delegate: LockIsolated<Delegate?> = .init(nil)
    private let state: LockIsolated<State> = .init(.idle)
    private let earnedReward: LockIsolated<Bool> = .init(false)

    @Dependency(\.adUnitID.webSocketConnectionRewardInterstitialAdUnitID)
    private var adUnitID
    @Dependency(\.continuousClock)
    private var continuousClock

    // MARK: - Delegate
    final class Delegate: NSObject, FullScreenContentDelegate, Sendable {
      // MARK: - Properties
      let earnRewarded: @Sendable (Int) -> Void

      // MARK: - Initialize
      init(earnRewarded: @Sendable @escaping (Int) -> Void) {
        self.earnRewarded = earnRewarded
      }

      // MARK: - FullScreenContentDelegate
      // swiftlint:disable:next identifier_name
      func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        guard let rewardedAd = ad as? RewardedInterstitialAd else { return }
        earnRewarded(rewardedAd.adReward.amount.intValue)
      }
    }

    func load() async throws {
      var retryCount = 0
      while retryCount < 5 {
        switch state.value {
        case .idle:
          state.setValue(.loading)
          do {
            let rewardedInterstitialAd = try await RewardedInterstitialAd.load(
              with: try adUnitID(),
              request: .init(),
            )
            state.setValue(.ready(rewardedInterstitialAd))
            return
          } catch {
            retryCount += 1
            state.setValue(.failed)
            try? await continuousClock.sleep(for: .milliseconds(500))
            state.setValue(.idle)
          }
        case .loading, .ready:
          return
        case .failed:
          state.setValue(.idle)
        }
      }
    }

    @MainActor
    func show() async throws -> Int {
      earnedReward.setValue(false)
      if case let .ready(rewardedInterstitialAd) = state.value {
        try rewardedInterstitialAd.canPresent()
        return try await withCheckedThrowingContinuation { [weak self] continuation in
          let delegate = Delegate { [weak self] amount in
            if self?.earnedReward.value == true {
              continuation.resume(returning: amount)
            } else {
              self?.state.setValue(.idle)
              continuation.resume(throwing: Error.interruption)
            }
            self?.delegate.setValue(nil)
          }
          self?.delegate.setValue(delegate)
          rewardedInterstitialAd.present(delegate: delegate) { [weak self] in
            self?.state.setValue(.idle)
            self?.earnedReward.setValue(true)
          }
        }
      }
      try await load()
      return try await show()
    }
  }
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
