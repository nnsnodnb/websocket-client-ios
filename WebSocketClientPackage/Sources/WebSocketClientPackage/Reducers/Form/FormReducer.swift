//
//  FormReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct FormReducer {
    // MARK: - State
    @ObservableState
    public struct State: Sendable, Equatable {
        var url: URL?
        var customHeaders: [CustomHeaderEntity] = []
        var isConnectButtonDisable = true
        @Presents var connection: ConnectionReducer.State?
    }

    // MARK: - Action
    public enum Action: Sendable, Equatable {
        case urlChanged(String)
        case addCustomHeader
        case removeCustomHeader(IndexSet)
        case customHeaderNameChanged(Int, String)
        case customHeaderValueChanged(Int, String)
        case connect
        case connectionOpen
        case connectionDismiss
        case connection(PresentationAction<ConnectionReducer.Action>)
    }

    @Dependency(\.date)
    var date
    @Dependency(\.uuid)
    var uuid

    public var body: some ReducerOf<Self> {
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
                let customHeader = CustomHeaderEntity(id: uuid.callAsFunction())
                state.customHeaders.append(customHeader)
                return .none
            case let .removeCustomHeader(indexSet):
                state.customHeaders.remove(atOffsets: indexSet)
                return .none
            case let .customHeaderNameChanged(index, name):
                guard !state.customHeaders.isEmpty,
                      var customHeader = state.customHeaders[safe: index] else { return .none }
                customHeader.setName(name)
                state.customHeaders[index] = customHeader
                return .none
            case let .customHeaderValueChanged(index, value):
                guard !state.customHeaders.isEmpty,
                      var customHeader = state.customHeaders[safe: index] else { return .none }
                customHeader.setValue(value)
                state.customHeaders[index] = customHeader
                return .none
            case .connect:
                guard let url = state.url else { return .none }
                let history = HistoryEntity(
                    id: uuid.callAsFunction(),
                    url: url,
                    customHeaders: state.customHeaders,
                    messages: [],
                    isConnectionSuccess: false,
                    createdAt: date.callAsFunction()
                )
                state.connection = .init(url: url, history: history)
                return .none
            case .connectionOpen:
                return .none
            case .connectionDismiss:
                state.connection = nil
                return .none
            case .connection(.presented(.close)):
                state.connection = nil
                return .none
            case .connection:
                return .none
            }
        }
        .ifLet(\.$connection, action: \.connection) {
            ConnectionReducer()
        }
    }
}
