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
    }

    // MARK: - Action
    enum Action: Equatable {
        case fetch
        case fetchResponse(TaskResult<[History]>)
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
            }
        }
    }
}
