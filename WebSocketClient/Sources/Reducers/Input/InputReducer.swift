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
        var customHeaders: [Int: CustomHeader] = [:]
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
                state.customHeaders[state.customHeaders.count] = .init(name: "", value: "")
                return .none
            case let .removeCustomHeader(indexSet):
                for index in indexSet {
                    state.customHeaders[index] = nil
                }
                return .none
            case let .customHeaderNameChanged(index, name):
                let customHeader: CustomHeader
                if let item = state.customHeaders[index] {
                    customHeader = .init(name: name, value: item.value)
                } else {
                    customHeader = .init(name: name, value: "")
                }
                state.customHeaders[index] = customHeader
                return .none
            case let .customHeaderValueChanged(index, value):
                let customHeader: CustomHeader
                if let item = state.customHeaders[index] {
                    customHeader = .init(name: item.name, value: value)
                } else {
                    customHeader = .init(name: "", value: value)
                }
                state.customHeaders[index] = customHeader
                return .none
            case .connect:
                // TODO: 接続
                return .none
            }
        }
    }
}
