//
//  FormReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import Foundation

struct FormReducer: ReducerProtocol {
    // MARK: - State
    struct State: Equatable {
        var url: URL?
        var customHeaders: [CustomHeader] = []
        var isConnectButtonDisable = true
    }

    // MARK: - Action
    enum Action: Equatable {
        case urlChanged(String)
        case addCustomHeader
        case removeCustomHeader(IndexSet)
        case customHeaderNameChanged(Int, String)
        case customHeaderValueChanged(Int, String)
        case connect
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .urlChanged(text):
                guard let url = URL(string: text) else {
                    state.url = nil
                    state.isConnectButtonDisable = true
                    return .none
                }
                state.url = url
                state.isConnectButtonDisable = false
                return .none
            case .addCustomHeader:
                state.customHeaders.append(.init(name: "", value: ""))
                return .none
            case let .removeCustomHeader(indexSet):
                state.customHeaders.remove(atOffsets: indexSet)
                return .none
            case let .customHeaderNameChanged(index, name):
                guard !state.customHeaders.isEmpty,
                      let customHeader = state.customHeaders[safe: index] else { return .none }
                state.customHeaders[index] = .init(name: name, value: customHeader.value)
                return .none
            case let .customHeaderValueChanged(index, value):
                guard !state.customHeaders.isEmpty,
                      let customHeader = state.customHeaders[safe: index] else { return .none }
                state.customHeaders[index] = .init(name: customHeader.name, value: value)
                return .none
            case .connect:
                // TODO: 接続
                return .none
            }
        }
    }
}
