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
        var connectivityState: ConnectivityState = .disconnected
        var message: String = ""
        var receivedMessages: [String] = []

        // MARK: - ConnectivityState
        enum ConnectivityState: String {
            case connected
            case connecting
            case disconnected
        }
    }

    // MARK: - Action
    enum Action: Equatable {
        case start
        case close
        case messageChanged(String)
        case receivedSocketMessage(TaskResult<WebSocketClient.Message>)
        case webSocket(WebSocketClient.Action)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.webSocketClient) var webSocketClient

    // MARK: - WebSocketID
    enum WebSocketID {}

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
                guard state.connectivityState == .disconnected else { return .none }
                state.connectivityState = .connecting
                return .run { [state] send in
                    var urlRequest = URLRequest(url: state.url)
                    state.customHeaders.forEach {
                        urlRequest.addValue($0.value, forHTTPHeaderField: $0.name)
                    }
                    let actions = await webSocketClient.open(WebSocketID.self, urlRequest)
                    await withThrowingTaskGroup(of: Void.self) { group in
                        for await action in actions {
                            group.addTask {
                                await send(.webSocket(action))
                            }
                            switch action {
                            case .didOpen:
                                group.addTask {
                                    while !Task.isCancelled {
                                        try await clock.sleep(for: .seconds(10))
                                        try? await webSocketClient.sendPing(WebSocketID.self)
                                    }
                                }
                                group.addTask {
                                    for await result in try await webSocketClient.receive(WebSocketID.self) {
                                        await send(.receivedSocketMessage(result))
                                    }
                                }
                            case .didClose:
                                print(action)
                                return
                            }
                        }
                    }
                }
                .cancellable(id: WebSocketID.self)
            case .close:
                state.connectivityState = .disconnected
                return .cancel(id: WebSocketID.self)
            case let .messageChanged(string):
                state.message = string
                return .none
            case let .receivedSocketMessage(.success(message)):
                guard case let .string(string) = message else { return .none }
                state.receivedMessages.append(string)
                return .none
            case .receivedSocketMessage(.failure):
                return .none
            case .webSocket(.didOpen):
                state.connectivityState = .connected
                state.receivedMessages.removeAll()
                return .none
            case .webSocket(.didClose):
                state.connectivityState = .disconnected
                return .cancel(id: WebSocketID.self)
            }
        }
    }
}
