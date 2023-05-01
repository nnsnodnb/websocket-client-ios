//
//  CustomHeaderListReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
import Foundation

struct CustomHeaderListReducer: ReducerProtocol {
    // MARK: - State
    struct State: Equatable {
        let customHeaders: [CustomHeader]
    }

    // MARK: - Action
    enum Action {
        case `default`
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, _ in
            return .none
        }
    }
}
