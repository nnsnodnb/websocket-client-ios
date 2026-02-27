//
//  ModelContextClient.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/14.
//

import Dependencies
import DependenciesMacros
import Foundation
import SwiftData

@DependencyClient
public struct ModelContextClient: Sendable {
  // MARK: - Properties
  public let make: @Sendable () -> ModelContext
}

// MARK: - DependencyKey
extension ModelContextClient: DependencyKey {
  public static let liveValue: Self = .init(
    make: {
      do {
        let container = try ModelContainer(
          for: HistoryModel.self, CustomHeaderModel.self, MessageModel.self,
        )
        return ModelContext(container)
      } catch {
        Logger.error("\(error)")
        fatalError("\(error)")
      }
    },
  )
  public static let testValue: Self = .init(
    make: {
      do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
          for: HistoryModel.self, CustomHeaderModel.self, MessageModel.self,
          configurations: config,
        )
        return ModelContext(container)
      } catch {
        Logger.error("\(error)")
        fatalError("\(error)")
      }
    },
  )
}

// MARK: - DependencyValues
public extension DependencyValues {
  var modelContext: ModelContextClient {
    get {
      self[ModelContextClient.self]
    }
    set {
      self[ModelContextClient.self] = newValue
    }
  }
}
