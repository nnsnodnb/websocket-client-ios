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
    }

    // MARK: - Action
    enum Action: Equatable {
        case checkDelete
        case confirm
        case alertDismissed
        case deleteResponse(TaskResult<Bool>)
        case deleted
    }

    @Dependency(\.databaseClient) var databaseClient

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .checkDelete:
                state.alert = AlertState(
                    title: {
                        TextState("本当に削除しますか？")
                    },
                    actions: {
                        ButtonState(
                            role: .cancel,
                            label: {
                                TextState("キャンセル")
                            }
                        )
                        ButtonState(
                            role: .destructive,
                            action: .send(.confirm),
                            label: {
                                TextState("削除")
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
                    TextState("削除に失敗しました")
                }
                return .none
            case .deleted:
                return .none
            }
        }
    }
}
