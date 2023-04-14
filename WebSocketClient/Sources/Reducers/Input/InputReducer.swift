//
//  InputReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import Foundation

struct InputReducer: ReducerProtocol {
    // MARK: - State
    struct State: Equatable {
        var url: URL?
    }

    // MARK: - Action
    enum Action: Equatable {
        case urlChanged(String)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .urlChanged(text):
                guard let url = URL(string: text) else {
                    return .none
                }
                state.url = url
                return .none
            }
        }
    }
}
