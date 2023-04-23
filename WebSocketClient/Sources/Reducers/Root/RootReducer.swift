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
        var version: String?
    }

    // MARK: - Action
    enum Action: Equatable {
        case onAppear
    }

    @Dependency(\.bundle) var bundle

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.version = bundle.shortVersionString()
                return .none
            }
        }
    }
}
