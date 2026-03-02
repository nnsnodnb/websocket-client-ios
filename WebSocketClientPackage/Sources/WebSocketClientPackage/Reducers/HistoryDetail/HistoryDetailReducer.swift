//
//  HistoryDetailReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/01.
//

import CasePaths
import Combine
import ComposableArchitecture
import Foundation

@Reducer
public struct HistoryDetailReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    let history: HistoryEntity
    @Presents var alert: AlertState<Action.Alert>?
    var isShowCustomHeaderList = false
  }

  // MARK: - Action
  public enum Action: Sendable, Equatable {
    case checkDelete
    case alert(PresentationAction<Alert>)
    case deleteResponse
    case deleted
    case showedCustomHeaderList(Bool)
    case error(Error)

    // MARK: - Alert
    public enum Alert: Sendable, Equatable {
      case confirm
    }

    // MARK: - Error
    @CasePathable
    public enum Error: Swift.Error {
      case delete
    }
  }

  @Dependency(\.database)
  var databaseClient

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .checkDelete:
        state.alert = AlertState(
          title: {
            TextState(.historyDetailAlertConfirmTitleMessage)
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState(.alertButtonTitleCancel)
              }
            )
            ButtonState(
              role: .destructive,
              action: .confirm,
              label: {
                TextState(.alertButtonTitleDelete)
              }
            )
          }
        )
        return .none
      case .alert(.dismiss):
        state.alert = nil
        return .none
      case .alert(.presented(.confirm)):
        return .run(
          operation: { [history = state.history] send in
            try await databaseClient.deleteHistory(history)
            await send(.deleteResponse)
          },
          catch: { error, send in
            await send(.error(.delete))
            Logger.error("Failed deleting: \(error)")
          }
        )
      case .deleteResponse:
        return .send(.deleted)
      case .deleted:
        return .none
      case let .showedCustomHeaderList(isOpened):
        state.isShowCustomHeaderList = isOpened
        return .none
      case .error(.delete):
        state.alert = AlertState {
          TextState(.historyDetailAlertDeletionFailedTitleMessage)
        }
        return .none
      }
    }
  }
}
