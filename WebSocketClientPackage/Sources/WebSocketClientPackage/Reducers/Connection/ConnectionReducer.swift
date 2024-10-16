//
//  ConnectionReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/17.
//

import CasePaths
import ComposableArchitecture
import Foundation

@Reducer
public struct ConnectionReducer: Sendable {
    // MARK: - State
    @ObservableState
    public struct State: Sendable, Equatable {
        let url: URL
        let customHeaders: [CustomHeaderEntity]
        var connectivityState: ConnectivityState = .disconnected
        var message: String = ""
        var isSendButtonDisabled = true
        var receivedMessages: [String] = []
        var history: HistoryEntity
        @Presents var alert: AlertState<Action.Alert>?
        var isShowCustomHeaderList = false

        // MARK: - ConnectivityState
        public enum ConnectivityState: String, Sendable {
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
    public enum Action: Sendable, Equatable {
        case start
        case close
        case messageChanged(String)
        case sendMessage
        case receivedSocketMessage(WebSocketClient.Message)
        case sendResponse
        case webSocket(WebSocketClient.Action)
        case addHistoryResponse
        case updateHistoryResponse
        case alert(PresentationAction<Alert>)
        case showedCustomHeaderList(Bool)
        case error(Error)

        // MARK: - Alert
        public enum Alert: Sendable, Equatable {
            case dismiss
        }

        // MARK: - Error
        @CasePathable
        public enum Error: Swift.Error {
            case receivedSocketMessage
            case send
            case addHistory
            case updateHistory
        }
    }

    @Dependency(\.continuousClock)
    var clock
    @Dependency(DatabaseClient.self)
    var databaseClient
    @Dependency(\.date)
    var date
    @Dependency(WebSocketClient.self)
    var webSocketClient
    @Dependency(\.uuid)
    var uuid

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .start:
                return runConnection(state: &state)
                    .merge(
                        with: .run(
                            operation: { [history = state.history] send in
                                try await databaseClient.addHistory(history)
                                await send(.addHistoryResponse)
                            },
                            catch: { error, send in
                                await send(.error(.addHistory))
                                Logger.error("Failed adding history: \(error)")
                            }
                        )
                    )
            case .close:
                state.connectivityState = .disconnected
                return .cancel(id: WebSocketClient.CancelID())
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
                        try await webSocketClient.send(WebSocketClient.CancelID(), .string(message))
                        await send(.sendResponse)
                    },
                    catch: { error, send in
                        await send(.error(.send))
                        Logger.error("Failed sening: \(error)")
                    }
                )
                .cancellable(id: WebSocketClient.CancelID())
            case let .receivedSocketMessage(message):
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
                        await send(.updateHistoryResponse)
                    },
                    catch: { error, send in
                        await send(.error(.updateHistory))
                        Logger.error("Failed updaing history: \(error)")
                    }
                )
            case .sendResponse:
                state.message = ""
                return .none
            case .webSocket(.didOpen):
                state.connectivityState = .connected
                state.receivedMessages.append("Connected \(state.url.absoluteString)")
                state.history.successfulConnection()
                return .run(
                    operation: { [history = state.history] send in
                        try await databaseClient.updateHistory(history)
                        await send(.updateHistoryResponse)
                    },
                    catch: { error, send in
                        await send(.error(.updateHistory))
                        Logger.error("Failed updaing history: \(error)")
                    }
                )
            case .webSocket(.didClose):
                state.connectivityState = .disconnected
                return .cancel(id: WebSocketClient.CancelID())
            case .alert(.dismiss):
                state.alert = nil
                return .none
            case .alert:
                return .none
            case .addHistoryResponse:
                return .none
            case .updateHistoryResponse:
                return .none
            case let .showedCustomHeaderList(isOpened):
                state.isShowCustomHeaderList = isOpened
                return .none
            case .error(.receivedSocketMessage):
                state.alert = AlertState {
                    TextState("Could not send socket message. Connect to the server first, and try again.")
                }
                return .none
            case .error(.send):
                return .none
            case .error(.addHistory):
                state.alert = AlertState {
                    TextState("Could not update history.")
                }
                return .none
            case .error(.updateHistory):
                state.alert = AlertState {
                    TextState("Could not update history.")
                }
                return .none
            }
        }
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
            let actions = try await webSocketClient.open(WebSocketClient.CancelID(), urlRequest)
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
                                try? await webSocketClient.sendPing(WebSocketClient.CancelID())
                            }
                        }
                        group.addTask {
                            for await result in try await webSocketClient.receive(WebSocketClient.CancelID()) {
                                switch result {
                                case let .success(message):
                                    await send(.receivedSocketMessage(message))
                                case let .failure(error):
                                    await send(.error(.receivedSocketMessage))
                                    Logger.error("WebSocket received error: \(error)")
                                }
                            }
                        }
                    case .didClose:
                        Logger.debug("Closed WebSocket connection")
                        return
                    }
                }
            }
        }
        .cancellable(id: WebSocketClient.CancelID())
    }
}
