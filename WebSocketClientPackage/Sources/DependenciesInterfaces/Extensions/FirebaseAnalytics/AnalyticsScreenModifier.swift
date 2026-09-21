//
//  AnalyticsScreenModifier.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/21.
//

import Dependencies
import SwiftUI

private struct AnalyticsScreenModifier: ViewModifier {
  let screenName: AnalyticsClient.ScreenName
  let parameters: [String: AnyHashableSendable]

  func body(content: Content) -> some View {
    content
      .task { @MainActor in
        @Dependency(\.analytics)
        var analytics

        await analytics.analyticsScreen(screenName, parameters)
      }
  }
}

public extension View {
  func analyticsScreen(
    screenName: AnalyticsClient.ScreenName,
    parameters: [String: AnyHashableSendable],
  ) -> some View {
    modifier(
      AnalyticsScreenModifier(
        screenName: screenName,
        parameters: parameters,
      )
    )
  }
}
