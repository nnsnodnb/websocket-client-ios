//
//  HistoryDetailReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/01.
//

import Combine
import ComposableArchitecture
import Foundation

@Reducer
public struct HistoryDetailReducer {
    // MARK: - State
    public struct State: Equatable {
        let history: HistoryEntity
        @PresentationState var alert: AlertState<Action.Alert>?
        var isShowCustomHeaderList = false
    }

    // MARK: - Action
    public enum Action: Equatable {
        case checkDelete
        case alert(PresentationAction<Alert>)
        case deleteResponse(TaskResult<Bool>)
        case deleted
        case showCustomHeaderList
        case dismissCustomHeaderList

        // MARK: - Alert
        public enum Alert: Equatable {
            case confirm
        }
    }

    @Dependency(\.databaseClient)
    var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .checkDelete:
                state.alert = AlertState(
                    title: {
                        TextState(L10n.HistoryDetail.Alert.Confirm.Title.message)
                    },
                    actions: {
                        ButtonState(
                            role: .cancel,
                            label: {
                                TextState(L10n.Alert.Button.Title.cancel)
                            }
                        )
                        ButtonState(
                            role: .destructive,
                            action: .confirm,
                            label: {
                                TextState(L10n.Alert.Button.Title.delete)
                            }
                        )
                    }
                )
                return .none
            case .alert(.presented(.confirm)):
                return .run(
                    operation: { [history = state.history] send in
                        try await databaseClient.deleteHistory(history)
                        await send(.deleteResponse(.success(true)))
                    },
                    catch: { error, send in
                        await send(.deleteResponse(.failure(error)))
                    }
                )
            case .alert:
                return .none
            case .deleteResponse(.success):
                return .send(.deleted)
            case let .deleteResponse(.failure(error)):
                state.alert = AlertState {
                    TextState(L10n.HistoryDetail.Alert.DeletionFailed.Title.message)
                }
                Logger.error("Failed deleting: \(error)")
                return .none
            case .deleted:
                return .none
            case .showCustomHeaderList:
                state.isShowCustomHeaderList = true
                return .none
            case .dismissCustomHeaderList:
                state.isShowCustomHeaderList = false
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
