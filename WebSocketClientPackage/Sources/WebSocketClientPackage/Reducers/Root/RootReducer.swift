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
    public var consent: ConsentReducer.State? = .init()
    public var form: FormReducer.State = .init()
    public var historyList: HistoryListReducer.State = .init()
    public var info: InfoReducer.State = .init()
    public var migratedToSwiftData = false

    // MARK: - Initialize
    public init(migratedToSwiftData: Bool = false) {
      self.migratedToSwiftData = migratedToSwiftData
    }
  }

  // MARK: - Action
  public enum Action {
    case migrateDatabase
    case showConsent
    case consent(ConsentReducer.Action)
    case form(FormReducer.Action)
    case historyList(HistoryListReducer.Action)
    case info(InfoReducer.Action)
  }

  @Dependency(\.database)
  private var database

  public var body: some ReducerOf<Self> {
    Scope(state: \.form, action: \.form) {
      FormReducer()
    }
    Scope(state: \.historyList, action: \.historyList) {
      HistoryListReducer()
    }
    Scope(state: \.info, action: \.info) {
      InfoReducer()
    }
    Reduce { state, action in
      switch action {
      case .migrateDatabase:
        guard !state.migratedToSwiftData else { return .none }
        return .run { send in
          try await database.migrateCoreDataToSwiftData()
          await send(.showConsent)
        }
      case .showConsent:
        state.consent = .init()
        state.migratedToSwiftData = true
        return .none
      case .consent(.delegate(.completedConsent)):
        state.consent = nil
        return .none
      case .consent:
        return .none
      case .form:
        return .none
      case .historyList:
        return .none
      case .info:
        return .none
      }
    }
    .ifLet(\.consent, action: \.consent) {
      ConsentReducer()
    }
  }

  // MARK: - Initialize
  public init() {
  }
}
