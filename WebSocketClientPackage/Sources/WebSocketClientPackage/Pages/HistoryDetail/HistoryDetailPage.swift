//
//  HistoryDetailPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/01.
//

import ComposableArchitecture
import DependenciesInterfaces
import SFSafeSymbols
import SwiftUI

@Reducer
public struct HistoryDetailReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    let history: HistoryEntity
    @Presents var alert: AlertState<Action.Alert>?
    var isShowCustomHeaderList = false
  }

  // MARK: - Action
  public enum Action {
    case checkDelete
    case alert(PresentationAction<Alert>)
    case deleteResponse
    case showedCustomHeaderList(Bool)
    case error(Error)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case deleted(HistoryEntity)
    }

    // MARK: - Alert
    public enum Alert: Sendable, Equatable {
      case confirm
    }

    // MARK: - Error
    @CasePathable
    public enum Error: Swift::Error {
      case delete
    }
  }

  @Dependency(\.database)
  var databaseClient

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .checkDelete:
        state.alert = AlertState(
          title: {
            TextState(.historyDetailAlertConfirmTitleMessage)
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState(.alertButtonTitleCancel)
              }
            )
            ButtonState(
              role: .destructive,
              action: .confirm,
              label: {
                TextState(.alertButtonTitleDelete)
              }
            )
          }
        )
        return .none
      case .alert(.presented(.confirm)):
        return .run(
          operation: { [history = state.history] send in
            try await databaseClient.deleteHistory(history)
            await send(.deleteResponse)
          },
          catch: { error, send in
            await send(.error(.delete))
            Logger.error("Failed deleting: \(error)")
          }
        )
      case .alert:
        return .none
      case .deleteResponse:
        return .send(.delegate(.deleted(state.history)))
      case let .showedCustomHeaderList(isOpened):
        state.isShowCustomHeaderList = isOpened
        return .none
      case .error(.delete):
        state.alert = AlertState {
          TextState(.historyDetailAlertDeletionFailedTitleMessage)
        }
        return .none
      case .delegate:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

struct HistoryDetailPage: View {
  @Bindable var store: StoreOf<HistoryDetailReducer>

  @Environment(\.horizontalSizeClass)
  private var horizontalSizeClass
  @Environment(\.verticalSizeClass)
  private var verticalSizeClass

  var body: some View {
    MessageListView(
      messages: store.history.messages.map { $0.text },
      connectivityState: .disconnected,
    )
    .navigationTitle(store.history.url.absoluteString)
    .toolbarTitleDisplayMode(.inline)
    .modifier {
      if #available(iOS 26.0, *) {
        $0
          .scrollEdgeEffectStyle(.soft, for: .top)
      } else {
        $0
      }
    }
    .toolbar(
      store: store,
      horizontalSizeClass: horizontalSizeClass,
      verticalSizeClass: verticalSizeClass,
    )
    .sheet(
      isPresented: $store.isShowCustomHeaderList.sending(
        \.showedCustomHeaderList
      ),
      content: {
        CustomHeaderListPage(customHeaders: store.history.customHeaders)
          .presentationDetents([.fraction(0.2), .large])
      }
    )
    .alert($store.scope(\.alert, action: \.alert))
    .analyticsScreen(screenName: .historyDetail)
  }
}

@MainActor
private extension View {
  @ViewBuilder
  func toolbar(
    store: StoreOf<HistoryDetailReducer>,
    horizontalSizeClass: UserInterfaceSizeClass?,
    verticalSizeClass: UserInterfaceSizeClass?,
  ) -> some View {
    let useInnerDisplay = horizontalSizeClass == .regular && verticalSizeClass == .regular

    toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Menu(
          content: {
            if !store.history.customHeaders.isEmpty {
              Button(
                action: {
                  store.send(.showedCustomHeaderList(true))
                },
                label: {
                  HStack {
                    Text(.historyDetailNavibarMenuTitleCheckCustomHeaders)
                    Image(systemSymbol: .checkmarkMessageFill)
                  }
                }
              )
            }
            Button(
              role: .destructive,
              action: {
                store.send(.checkDelete)
              },
              label: {
                HStack {
                  Text(.historyDetailNavibarMenuTitleDelete)
                  Image(systemSymbol: .trash)
                }
              }
            )
          },
          label: {
            Image(systemSymbol: UIDevice.current.isLiquidEffectEnabled ? .ellipsis : .ellipsisCircle)
          }
        )
      }
    }
    .toolbarRole(.editor)
    .toolbar(useInnerDisplay ? .visible : .hidden, for: .tabBar)
  }
}

struct HistoryDetailPage_Previews: PreviewProvider {
  static var history: HistoryEntity {
    var customHeader = CustomHeaderEntity(id: .init(0))
    customHeader.setName("name")
    customHeader.setValue("value")
    let message = MessageEntity(id: .init(0), text: "Hello", createdAt: .init())
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.socket.events")!,
      customHeaders: [customHeader],
      messages: [message],
      isConnectionSuccess: true,
      createdAt: .init()
    )
    return history
  }

  static var previews: some View {
    NavigationStack {
      HistoryDetailPage(
        store: .init(
          initialState: HistoryDetailReducer.State(
            history: history
          )
        ) {
          HistoryDetailReducer()
        }
      )
    }
  }
}
