//
//  HistoryDetailReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/01.
//

import ComposableArchitecture
import Foundation

struct HistoryDetailReducer: ReducerProtocol {
    // MARK: - State
    struct State: Equatable {
        let history: History
        var alert: AlertState<Action>?
        var isShowCustomHeaderList = false
    }

    // MARK: - Action
    enum Action: Equatable {
        case checkDelete
        case confirm
        case alertDismissed
        case deleteResponse(TaskResult<Bool>)
        case deleted
        case showCustomHeaderList
        case dismissCustomHeaderList
    }

    @Dependency(\.databaseClient)
    var databaseClient

    var body: some ReducerProtocol<State, Action> {
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
                            action: .send(.confirm),
                            label: {
                                TextState(L10n.Alert.Button.Title.delete)
                            }
                        )
                    }
                )
                return .none
            case .confirm:
                return .task { [state] in
                    await .deleteResponse(
                        TaskResult {
                            try await databaseClient.deleteHistory(state.history)
                            return true
                        }
                    )
                }
            case .alertDismissed:
                state.alert = nil
                return .none
            case .deleteResponse(.success):
                return .send(.deleted)
            case .deleteResponse(.failure):
                state.alert = AlertState {
                    TextState(L10n.HistoryDetail.Alert.DeletionFailed.Title.message)
                }
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
    }
}
