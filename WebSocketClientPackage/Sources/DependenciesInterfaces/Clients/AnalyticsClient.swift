//
//  AnalyticsClient.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/21.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AnalyticsClient: Sendable {
  public var logEvent: @Sendable (Event) async -> Void = { _ in }
  public var analyticsScreen: @Sendable (ScreenName, [String: Any]) async -> Void = { _, _ in }
}

// MARK: - DependencyKey
extension AnalyticsClient: DependencyKey {
  public static let liveValue: Self = .init(
    logEvent: { _ in },
    analyticsScreen: { _, _ in },
  )
  public static let testValue: Self = .init(
    logEvent: { _ in },
    analyticsScreen: { _, _ in },
  )
}

// MARK: - Event
public extension AnalyticsClient {
  enum Event {
    case urlTapped(URL)

    // MARK: - Properties
    public var eventName: String {
      switch self {
      case .urlTapped:
        "url_tapped"
      }
    }

    public var parameters: [String: Any] {
      switch self {
      case let .urlTapped(url):
        [
          "url": url.absoluteString,
        ]
      }
    }
  }
}

// MARK: - ScreenName
public extension AnalyticsClient {
  enum ScreenName: String, Sendable {
    case form = "form-page"
    case connection = "connection-page"
    case customHeaderList = "custom-header-list-page"
    case historyList = "history-list-page"
    case historyDetail = "history-detail-page"
    case info = "info-page"
  }
}

// MARK: - DependencyValues
public extension DependencyValues {
  var analytics: AnalyticsClient {
    get {
      self[AnalyticsClient.self]
    }
    set {
      self[AnalyticsClient.self] = newValue
    }
  }
}
