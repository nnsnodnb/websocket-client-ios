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
        case form(FormReducer.State)
    }

    // MARK: - Action
    enum Action: Equatable {
        case form(FormReducer.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            // TODO: とりあえずなので後で直す
            return .none
        }
        .ifCaseLet(/State.form, action: /Action.form) {
            FormReducer()
        }
    }
}
