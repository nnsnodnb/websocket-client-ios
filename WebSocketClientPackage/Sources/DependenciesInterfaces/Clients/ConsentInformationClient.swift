//
//  ConsentInformationClient.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct ConsentInformationClient: Sendable {
  public var requestConsent: @Sendable () async throws -> Bool
  public var load: @Sendable (Bool) async throws -> Void
  public var visiblePrivacyOptionsRequirements: @Sendable () -> Bool = { false }
  public var presentPrivacyOptions: @Sendable () async throws -> Void
}

// MARK: - DependencyKey
extension ConsentInformationClient: DependencyKey {
  public static let liveValue: ConsentInformationClient = .init(
    requestConsent: { false },
    load: { _ in },
    visiblePrivacyOptionsRequirements: { false },
    presentPrivacyOptions: {},
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var consentInformation: ConsentInformationClient {
    get {
      self[ConsentInformationClient.self]
    }
    set {
      self[ConsentInformationClient.self] = newValue
    }
  }
}
