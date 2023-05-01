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
    }

    // MARK: - Action
    enum Action: Equatable {
        case `default`
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
