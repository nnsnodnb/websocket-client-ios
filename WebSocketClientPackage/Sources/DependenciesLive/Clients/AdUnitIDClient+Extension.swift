//
//  AdUnitIDClient+Extension.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/21.
//

import DependenciesInterfaces
import Foundation

public extension AdUnitIDClient {
  static let debug: Self = .init(
    formAboveBannerAdUnitID: { "ca-app-pub-3940256099942544/2435281174" },
    webSocketConnectionRewardInterstitialAdUnitID: { "ca-app-pub-3940256099942544/6978759866" },
  )
  static let release: Self = .init(
    formAboveBannerAdUnitID: { "ca-app-pub-3417597686353524/4750338458" },
    webSocketConnectionRewardInterstitialAdUnitID: { "ca-app-pub-3417597686353524/4189676656" },
  )
}
