//
//  RootReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import Foundation

public struct RootReducer: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        // MARK: - Initialize
        public init() {
        }
    }

    // MARK: - Action
    public struct Action: Equatable {
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { _, _ in
            return .none
        }
    }

    // MARK: - Initialize
    public init() {
    }
}
