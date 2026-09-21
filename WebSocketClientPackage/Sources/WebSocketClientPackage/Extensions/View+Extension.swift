//
//  View+Extension.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/19.
//

import ConcurrencyExtras
import DependenciesInterfaces
import SwiftUI

extension View {
  func modifier(@ViewBuilder _ closure: (Self) -> some View) -> some View {
    closure(self)
  }
}

extension View {
  func analyticsScreen(
    screenName: AnalyticsClient.ScreenName,
    extraParameters: [String: AnyHashableSendable] = [:],
  ) -> some View {
    analyticsScreen(screenName: screenName, parameters: extraParameters)
  }
}
