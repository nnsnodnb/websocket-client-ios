//
//  AnalyticsClient+Extension.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/21.
//

import DependenciesInterfaces
import FirebaseAnalytics
import Foundation

public extension AnalyticsClient {
  static let firebase: Self = .init(
    logEvent: { event in
      Analytics.logEvent(
        event.eventName,
        parameters: event.parameters,
      )
    },
    analyticsScreen: { screenName, parameters in
      var parameters = parameters
      parameters[AnalyticsParameterScreenName] = screenName.rawValue
      parameters[AnalyticsParameterScreenClass] = "Class"
      Analytics.logEvent(
        AnalyticsEventScreenView,
        parameters: parameters,
      )
    },
  )
}
