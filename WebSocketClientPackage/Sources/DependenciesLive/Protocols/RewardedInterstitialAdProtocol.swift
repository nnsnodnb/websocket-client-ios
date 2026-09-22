//
//  RewardedInterstitialAdProtocol.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import Foundation
import GoogleMobileAds

@MainActor
package protocol RewardedInterstitialAdProtocol: Equatable, Sendable {
  func canPresent() throws
  func present(delegate: (any FullScreenContentDelegate)?, userDidEarnRewardHandler: @escaping () -> Void)
}
