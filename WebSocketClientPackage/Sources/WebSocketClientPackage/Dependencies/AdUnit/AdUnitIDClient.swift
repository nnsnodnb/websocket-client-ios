//
//  AdUnitIDClient.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/28.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AdUnitIDClient: Sendable {
  // MARK: - Properties
  public var formAboveBannerAdUnitID: @Sendable () throws -> String
}

// MARK: - DependencyKey
extension AdUnitIDClient: DependencyKey {
  public static let liveValue: Self = .init(
    formAboveBannerAdUnitID: { throw Error.mustSetAdIDFromRootPage },
  )
}

// MARK: - Error
public extension AdUnitIDClient {
  enum Error: Swift.Error {
    case mustSetAdIDFromRootPage
  }
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
