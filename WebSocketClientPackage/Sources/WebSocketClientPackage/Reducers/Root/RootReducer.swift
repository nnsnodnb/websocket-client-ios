//
//  RootReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import Foundation

public struct RootReducer: Reducer {
    // MARK: - State
    public struct State: Equatable {
        // MARK: - Initialize
        public init() {
        }
    }

    // MARK: - Action
    public struct Action: Equatable {
    }

    public var body: some Reducer<State, Action> {
        Reduce { _, _ in
            return .none
        }
    }

    // MARK: - Initialize
    public init() {
    }
}
