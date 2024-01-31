//
//  RootReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct RootReducer {
    // MARK: - State
    @ObservableState
    public struct State: Equatable {
        // MARK: - Initialize
        public init() {
        }
    }

    // MARK: - Action
    public struct Action: Equatable {
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, _ in
            return .none
        }
    }

    // MARK: - Initialize
    public init() {
    }
}
