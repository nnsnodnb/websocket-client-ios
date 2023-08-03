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
        let customHeaders: [CustomHeaderEntity]
        var connectivityState: ConnectivityState = .disconnected
        var message: String = ""
        var isSendButtonDisabled = true
        var receivedMessages: [String] = []
        var history: HistoryEntity
        var alert: AlertState<Action>?
        var isShowCustomHeaderList = false

        // MARK: - ConnectivityState
        enum ConnectivityState: String {
            case connected
            case connecting
            case disconnected
        }

        // MARK: - Initialize
        init(url: URL, history: HistoryEntity) {
            self.url = url
            self.customHeaders = history.customHeaders
            self.history = history
        }
    }

    // MARK: - Action
    enum Action: Equatable {
        case start
        case close
        case messageChanged(String)
        case sendMessage
        case receivedSocketMessage(TaskResult<WebSocketClient.Message>)
        case sendResponse(TaskResult<Bool>)
        case webSocket(WebSocketClient.Action)
        case addHistoryResponse(TaskResult<Bool>)
        case updateHistoryResponse(TaskResult<Bool>)
        case alertDismissed
        case showCustomHeaderList
        case dismissCustomHeaderList
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

    var body: some ReducerProtocol<State, Action> {
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
                return .task { [message = state.message] in
                    await .sendResponse(
                        TaskResult {
                            try await webSocketClient.send(CancelID.websocket, .string(message))
                            return true
                        }
                    )
                }
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
                return .task { [history = state.history] in
                    await .updateHistoryResponse(
                        TaskResult {
                            try await databaseClient.updateHistory(history)
                            return true
                        }
                    )
                }
            case .sendResponse(.success):
                state.message = ""
                return .none
            case .sendResponse(.failure):
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
                return .task { [history = state.history] in
                    await .updateHistoryResponse(
                        TaskResult {
                            try await databaseClient.updateHistory(history)
                            return true
                        }
                    )
                }
            case .webSocket(.didClose):
                state.connectivityState = .disconnected
                return .cancel(id: CancelID.websocket)
            case .alertDismissed:
                state.alert = nil
                return .none
            case .addHistoryResponse(.success):
                return .none
            case .addHistoryResponse(.failure):
                state.alert = AlertState {
                    TextState("Could not update history.")
                }
                return .none
            case .updateHistoryResponse(.success):
                return .none
            case .updateHistoryResponse(.failure):
                state.alert = AlertState {
                    TextState("Could not update history.")
                }
                return .none
            case .showCustomHeaderList:
                state.isShowCustomHeaderList = true
                return .none
            case .dismissCustomHeaderList:
                state.isShowCustomHeaderList = false
                return .none
            }
        }
    }

    private func runConnection(state: inout State) -> EffectTask<Action> {
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
                        return
                    }
                }
            }
        }
        .cancellable(id: CancelID.websocket)
        .merge(
            with: .task { [state] in
                await .addHistoryResponse(
                    TaskResult {
                        try await databaseClient.addHistory(state.history)
                        return true
                    }
                )
            }
        )
    }
}
