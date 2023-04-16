//
//  ConnectionReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/17.
//

import ComposableArchitecture
import Foundation

struct ConnectionReducer: ReducerProtocol {
    // MARK: - State
    struct State: Equatable {
        let url: URL
        let customHeaders: [CustomHeader]
    }

    // MARK: - Action
    enum Action {
        case start
        case close
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
//                return .run(
//                    priority: .background,
//                    operation: <#T##(Send<Action>) async throws -> Void#>
//                )
                return .none
            case .close:
                return .none
            }
        }
    }
}
