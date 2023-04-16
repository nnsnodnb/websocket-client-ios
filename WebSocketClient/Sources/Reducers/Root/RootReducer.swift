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
    struct State: Equatable {
    }

    // MARK: - Action
    struct Action: Equatable {
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, _ in
            return .none
        }
    }
}
