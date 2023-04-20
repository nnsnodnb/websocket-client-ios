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
    }

    // MARK: - Action
    enum Action: Equatable {
        case `default`
    }

    @Dependency(\.databaseClient) var databaseClient

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
