//
//  RootReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import Foundation

struct RootReducer: ReducerProtocol {
    // MARK: - State
    enum State: Equatable {
        case input(InputReducer.State)
    }

    // MARK: - Action
    enum Action: Equatable {
        case input(InputReducer.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            // TODO: とりあえずなので後で直す
            return .none
        }
        .ifCaseLet(/State.input, action: /Action.input) {
            InputReducer()
        }
    }
}
