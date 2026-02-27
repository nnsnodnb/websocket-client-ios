//
//  RootReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct RootReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    public var migratedToSwiftData = false
  }

  // MARK: - Action
  public enum Action: Equatable {
    case migrateDatabase
    case migratedDatabase
  }

  @Dependency(\.database)
  private var database

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .migrateDatabase:
        guard !state.migratedToSwiftData else { return .none }
        return .run { send in
          try await database.migrateCoreDataToSwiftData()
          await send(.migratedDatabase)
        }
      case .migratedDatabase:
        state.migratedToSwiftData = true
        return .none
      }
    }
  }

  // MARK: - Initialize
  public init() {
  }
}
