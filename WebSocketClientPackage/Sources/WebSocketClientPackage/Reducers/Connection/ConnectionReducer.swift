//
//  ConnectionReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/17.
//

import ComposableArchitecture
import Foundation

public struct ConnectionReducer: Reducer {
    // MARK: - State
    public struct State: Equatable {
        let url: URL
        let customHeaders: [CustomHeaderEntity]
        var connectivityState: ConnectivityState = .disconnected
        var message: String = ""
        var isSendButtonDisabled = true
        var receivedMessages: [String] = []
        var history: HistoryEntity
        @PresentationState var alert: AlertState<Action.Alert>?
        var isShowCustomHeaderList = false

        // MARK: - ConnectivityState
        public enum ConnectivityState: String {
            case connected
            case connecting
            case disconnected
        }

        // MARK: - Initialize
        public init(url: URL, history: HistoryEntity) {
            self.url = url
            self.customHeaders = history.customHeaders
            self.history = history
        }
    }

    // MARK: - Action
    public enum Action: Equatable {
        case start
        case close
        case messageChanged(String)
        case sendMessage
        case receivedSocketMessage(TaskResult<WebSocketClient.Message>)
        case sendResponse(TaskResult<Bool>)
        case webSocket(WebSocketClient.Action)
        case addHistoryResponse(TaskResult<Bool>)
        case updateHistoryResponse(TaskResult<Bool>)
        case alert(PresentationAction<Alert>)
        case showCustomHeaderList
        case dismissCustomHeaderList

        // MARK: - Alert
        public enum Alert: Equatable {
            case dismiss
        }
    }

    @Dependency(\.continuousClock)
    var clock
    @Dependency(\.databaseClient)
    var databaseClient
    @Dependency(\.date)
    var date
    @Dependency(\.webSocketClient)
    var webSocketClient
    @Dependency(\.uuid)
    var uuid

    // MARK: - WebSocketID
    enum CancelID {
        case websocket
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
                return runConnection(state: &state)
            case .close:
                state.connectivityState = .disconnected
                return .cancel(id: CancelID.websocket)
            case let .messageChanged(string):
                state.message = string
                switch state.connectivityState {
                case .connected:
                    state.isSendButtonDisabled = string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                case .connecting, .disconnected:
                    state.isSendButtonDisabled = true
                }
                return .none
            case .sendMessage:
                return .run(
                    operation: { [message = state.message] send in
                        try await webSocketClient.send(CancelID.websocket, .string(message))
                        await send(.sendResponse(.success(true)))
                    },
                    catch: { error, send in
                        await send(.sendResponse(.failure(error)))
                    }
                )
                .cancellable(id: CancelID.websocket)
            case let .receivedSocketMessage(.success(message)):
                guard case let .string(string) = message else { return .none }
                state.receivedMessages.append(string)
                let message = MessageEntity(
                    id: uuid.callAsFunction(),
                    text: string,
                    createdAt: date.callAsFunction()
                )
                state.history.addToMessages(message)
                return .run(
                    operation: { [history = state.history] send in
                        try await databaseClient.updateHistory(history)
                        await send(.updateHistoryResponse(.success(true)))
                    },
                    catch: { error, send in
                        await send(.updateHistoryResponse(.failure(error)))
                    }
                )
            case .sendResponse(.success):
                state.message = ""
                return .none
            case let .sendResponse(.failure(error)):
                Logger.error("Failed sening: \(error)")
                return .none
            case .receivedSocketMessage(.failure):
                state.alert = AlertState {
                    TextState("Could not send socket message. Connect to the server first, and try again.")
                }
                return .none
            case .webSocket(.didOpen):
                state.connectivityState = .connected
                state.receivedMessages.append("Connected \(state.url.absoluteString)")
                state.history.successfulConnection()
                return .run(
                    operation: { [history = state.history] send in
                        try await databaseClient.updateHistory(history)
                        await send(.updateHistoryResponse(.success(true)))
                    },
                    catch: { error, send in
                        await send(.updateHistoryResponse(.failure(error)))
                    }
                )
            case .webSocket(.didClose):
                state.connectivityState = .disconnected
                return .cancel(id: CancelID.websocket)
            case .alert:
                return .none
            case .addHistoryResponse(.success):
                return .none
            case let .addHistoryResponse(.failure(error)):
                state.alert = AlertState {
                    TextState("Could not update history.")
                }
                Logger.error("Failed adding history: \(error)")
                return .none
            case .updateHistoryResponse(.success):
                return .none
            case let .updateHistoryResponse(.failure(error)):
                state.alert = AlertState {
                    TextState("Could not update history.")
                }
                Logger.error("Failed updaing history: \(error)")
                return .none
            case .showCustomHeaderList:
                state.isShowCustomHeaderList = true
                return .none
            case .dismissCustomHeaderList:
                state.isShowCustomHeaderList = false
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }

    private func runConnection(state: inout State) -> Effect<Action> {
        guard state.connectivityState == .disconnected else { return .none }
        state.receivedMessages = ["Connecting to \(state.url.absoluteString)"]
        state.connectivityState = .connecting
        return .run { [state] send in
            var urlRequest = URLRequest(url: state.url)
            state.customHeaders.forEach {
                urlRequest.addValue($0.value, forHTTPHeaderField: $0.name)
            }
            let actions = await webSocketClient.open(CancelID.websocket, urlRequest)
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
                                try? await webSocketClient.sendPing(CancelID.websocket)
                            }
                        }
                        group.addTask {
                            for await result in try await webSocketClient.receive(CancelID.websocket) {
                                await send(.receivedSocketMessage(result))
                            }
                        }
                    case .didClose:
                        Logger.debug("Closed WebSocket connection")
                        return
                    }
                }
            }
        }
        .cancellable(id: CancelID.websocket)
        .merge(
            with: .run(
                operation: { [history = state.history] send in
                    try await databaseClient.addHistory(history)
                    await send(.addHistoryResponse(.success(true)))
                },
                catch: { error, send in
                    await send(.addHistoryResponse(.failure(error)))
                }
            )
        )
    }
}
