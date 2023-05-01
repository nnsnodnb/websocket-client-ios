//
//  HistoryListReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

import ComposableArchitecture
import Foundation

struct HistoryListReducer: ReducerProtocol {
    // MARK: - State
    struct State: Equatable {
        var histories: IdentifiedArrayOf<History> = []
        var selectionHistory: Identified<History, HistoryDetailReducer.State?>?
    }

    // MARK: - Action
    enum Action: Equatable {
        case fetch
        case fetchResponse(TaskResult<[History]>)
        case setNavigation(History?)
        case historyDetail(HistoryDetailReducer.Action)
    }

    @Dependency(\.databaseClient) var databaseClient

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetch:
                return .task {
                    await .fetchResponse(
                        TaskResult {
                            try await databaseClient.fetchHistories {
                                $0.filter("isConnectionSuccess == %@", true)
                            }
                        }
                    )
                }
            case let .fetchResponse(.success(histories)):
                state.histories = .init(uniqueElements: histories)
                return .none
            case .fetchResponse(.failure):
                return .none
            case let .setNavigation(.some(history)):
                state.selectionHistory = .init(.init(history: history), id: history)
                return .none
            case .setNavigation(.none):
                state.selectionHistory = nil
                return .none
            case .historyDetail:
                return .none
            }
        }
        .ifLet(\.selectionHistory, action: /Action.historyDetail) {
            EmptyReducer()
                .ifLet(\.value, action: .self) {
                    HistoryDetailReducer()
                }
        }
    }
}
