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
        var customHeaders: [CDCustomHeader] = []
        var isConnectButtonDisable = true
        var connection: ConnectionReducer.State?
    }

    // MARK: - Action
    enum Action: Equatable {
        case urlChanged(String)
        case addCustomHeader
        case removeCustomHeader(IndexSet)
        case customHeaderNameChanged(Int, String)
        case customHeaderValueChanged(Int, String)
        case connect
        case connectionOpen
        case connectionDismiss
        case connection(ConnectionReducer.Action)
    }

    @Dependency(\.databaseClient)
    var databaseClient
    @Dependency(\.date)
    var date
    @Dependency(\.uuid)
    var uuid

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
                let customHeader = CDCustomHeader(context: databaseClient.managedObjectContext())
                customHeader.id = uuid.callAsFunction()
                customHeader.name = ""
                customHeader.value = ""
                state.customHeaders.append(customHeader)
                return .none
            case let .removeCustomHeader(indexSet):
                state.customHeaders.remove(atOffsets: indexSet)
                return .none
            case let .customHeaderNameChanged(index, name):
                guard !state.customHeaders.isEmpty,
                      let customHeader = state.customHeaders[safe: index] else { return .none }
                customHeader.name = name
                state.customHeaders[index] = customHeader
                return .none
            case let .customHeaderValueChanged(index, value):
                guard !state.customHeaders.isEmpty,
                      let customHeader = state.customHeaders[safe: index] else { return .none }
                customHeader.value = value
                state.customHeaders[index] = customHeader
                return .none
            case .connect:
                guard let url = state.url else { return .none }
                let history = CDHistory(context: databaseClient.managedObjectContext())
                history.id = uuid.callAsFunction()
                history.urlString = url.absoluteString
                state.customHeaders.forEach(history.addToCustomHeaders)
                history.createdAt = date.callAsFunction()
                state.connection = .init(url: url, history: history)
                return .none
            case .connectionOpen:
                return .none
            case .connectionDismiss:
                state.connection = nil
                return .none
            case .connection(.close):
                state.connection = nil
                return .none
            case .connection:
                return .none
            }
        }
        .ifLet(\.connection, action: /Action.connection) {
            ConnectionReducer()
        }
    }
}
