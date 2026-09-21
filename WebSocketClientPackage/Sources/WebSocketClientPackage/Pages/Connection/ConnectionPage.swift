//
//  ConnectionPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/17.
//

import ComposableArchitecture
import DependenciesInterfaces
import SwiftUI

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
    public init(url: URL, history: HistoryEntity, isShowCustomHeaderList: Bool = false) {
      self.url = url
      self.customHeaders = history.customHeaders
      self.history = history
      self.isShowCustomHeaderList = isShowCustomHeaderList
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
  @Dependency(\.database)
  var databaseClient
  @Dependency(\.date)
  var date
  @Dependency(\.webSocket)
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
          TextState(.connectionAlertSendTitle)
        }
        return .none
      case .error(.send):
        return .none
      case .error(.addHistory):
        state.alert = AlertState {
          TextState(.connectionAlertUpdateTitle)
        }
        return .none
      case .error(.updateHistory):
        state.alert = AlertState {
          TextState(.connectionAlertUpdateTitle)
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
          }
        }
      }
    }
    .cancellable(id: WebSocketClient.CancelID())
  }
}

struct ConnectionPage: View {
  @Bindable var store: StoreOf<ConnectionReducer>

  var body: some View {
    NavigationStack {
      content
        .navigationTitle(store.url.absoluteString)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(store: store)
    }
    .alert($store.scope(\.alert, action: \.alert))
    .sheet(
      isPresented: $store.isShowCustomHeaderList.sending(\.showedCustomHeaderList),
      content: {
        CustomHeaderListPage(customHeaders: store.customHeaders)
          .presentationDetents([.fraction(0.2), .large])
      }
    )
    .task {
      store.send(.start)
    }
    .analyticsScreen(screenName: .connection)
  }

  private var content: some View {
    VStack(spacing: 0) {
      messageTextField
      receivedMessageList
    }
  }

  private var messageTextField: some View {
    HStack {
      TextField(
        String(localized: .connectionTextFieldPlaceholder),
        text: $store.message.sending(\.messageChanged)
      )
      .frame(height: 44)
      Button(
        action: {
          store.send(.sendMessage)
        },
        label: {
          Text(.connectionTitleSendButton)
            .bold()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      )
      .disabled(store.isSendButtonDisabled)
      .frame(width: 80)
    }
    .padding(.horizontal)
    .frame(height: 44)
    .backgroundStyle(Color.clear)
  }

  private var receivedMessageList: some View {
    MessageListView(messages: store.receivedMessages)
  }
}

@MainActor
private extension View {
  func toolbar(store: StoreOf<ConnectionReducer>) -> some View {
    toolbar {
      ToolbarItem(placement: .cancellationAction) {
        if #available(iOS 26.0, *) {
          Button(role: .cancel) {
            store.send(.close)
          }
        } else {
          Button(
            action: {
              store.send(.close)
            },
            label: {
              Image(systemSymbol: .xmark)
                .resizable()
                .frame(maxWidth: 44, maxHeight: 44)
                .fontWeight(.medium)
            }
          )
        }
      }
      if !store.customHeaders.isEmpty {
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu(
            content: {
              Button(
                action: {
                  store.send(.showedCustomHeaderList(true))
                },
                label: {
                  HStack {
                    Text(.connectionNavibarMenuTitleCheckCustomHeaders)
                    Image(systemSymbol: .checkmarkMessageFill)
                  }
                }
              )
            },
            label: {
              if #available(iOS 26.0, *) {
                Image(systemSymbol: .ellipsis)
              } else {
                Image(systemSymbol: .ellipsisCircle)
              }
            }
          )
        }
      }
    }
  }
}

struct ConnectionPage_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ConnectionPage(
        store: .init(
          initialState: ConnectionReducer.State(
            url: URL(string: "wss://echo.websocket.org")!,
            history: .init(
              id: .init(0),
              url: URL(string: "wss://echo.websocket.org")!,
              customHeaders: [],
              messages: [],
              isConnectionSuccess: false,
              createdAt: .init()
            )
          )
        ) {
          ConnectionReducer()
        }
      )
      .previewDisplayName("Empty custom header")
      ConnectionPage(
        store: .init(
          initialState: ConnectionReducer.State(
            url: URL(string: "wss://echo.websocket.org")!,
            history: {
              var customHeader = CustomHeaderEntity(id: .init(1))
              customHeader.setName("name")
              customHeader.setValue("value")
              return .init(
                id: .init(1),
                url: URL(string: "wss://echo.websocket.org")!,
                customHeaders: [customHeader],
                messages: [],
                isConnectionSuccess: false,
                createdAt: .init()
              )
            }()
          )
        ) {
          ConnectionReducer()
        }
      )
      .previewDisplayName("Exist custom headers")
    }
  }
}
