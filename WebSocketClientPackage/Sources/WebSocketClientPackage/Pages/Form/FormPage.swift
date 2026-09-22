//
//  FormPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import DependenciesInterfaces
import SFSafeSymbols
import SwiftUI

@Reducer
public struct FormReducer: Sendable {
  // MARK: - Destination
  @Reducer
  public enum Destination {
    case connection(ConnectionReducer)
    case alert(AlertState<Alert>)

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case watch(URL)
    }
  }

  // MARK: - State
  @ObservableState
  public struct State: Sendable, Equatable {
    var adUnitID: String?
    var url: URL?
    var customHeaders: [CustomHeaderEntity] = []
    var isConnectButtonDisable = true
    @Presents var destination: Destination.State?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case preloadRewardedInterstitialAd
    case urlChanged(String)
    case addCustomHeader
    case removeCustomHeader(IndexSet)
    case customHeaderNameChanged(Int, String)
    case customHeaderValueChanged(Int, String)
    case showBeforeAdsAlert
    case connect(URL)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.adUnitID)
  var adUnitID
  @Dependency(\.date)
  var date
  @Dependency(\.rewardInterstitialAd)
  var rewardInterstitialAd
  @Dependency(\.uuid)
  var uuid

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.adUnitID = try? adUnitID.formAboveBannerAdUnitID()
        return .send(.preloadRewardedInterstitialAd)
      case .preloadRewardedInterstitialAd:
        return .run(
          priority: .background,
          operation: { _ in
            try await rewardInterstitialAd.load()
          },
        )
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
      case .showBeforeAdsAlert:
        guard let url = state.url, !state.isConnectButtonDisable else { return .none }
        state.destination = .alert(
          .init(
            title: {
              TextState(.formAlertWatchTitle)
            },
            actions: {
              ButtonState(
                role: .cancel,
                label: {
                  TextState(.alertButtonTitleCancel)
                },
              )
              ButtonState(
                action: .watch(url),
                label: {
                  TextState(.formAlertWatchTitleContinue)
                },
              )
            },
          )
        )
        return .run(
          operation: { send in
            let result = try await rewardInterstitialAd.show()
            if result > 0 {
              await send(.connect(url))
            }
            await send(.preloadRewardedInterstitialAd)
          },
          catch: { _, send in
            await send(.preloadRewardedInterstitialAd)
          },
        )
      case let .connect(url):
        let history = HistoryEntity(
          id: uuid.callAsFunction(),
          url: url,
          customHeaders: state.customHeaders,
          messages: [],
          isConnectionSuccess: false,
          createdAt: date.callAsFunction()
        )
        state.destination = .connection(.init(url: url, history: history))
        return .none
      case let .destination(.presented(.alert(.watch(url)))):
        state.destination = nil
        return .run(
          operation: { send in
            let result = try await rewardInterstitialAd.show()
            if result > 0 {
              await send(.connect(url))
            }
            await send(.preloadRewardedInterstitialAd)
          },
          catch: { _, send in
            await send(.preloadRewardedInterstitialAd)
          },
        )
      case .destination(.presented(.alert)):
        state.destination = nil
        return .none
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

// MARK: - FormReducer.Destination.State Equatable
extension FormReducer.Destination.State: Equatable {}

// MARK: - FormReducer.Destination.State Sendable
extension FormReducer.Destination.State: Sendable {}

struct FormPage: View {
  @Bindable var store: StoreOf<FormReducer>

  @FocusState private var isFocused: Bool

  @Dependency(\.adClient)
  private var adClient

  var body: some View {
    NavigationStack {
      form
        .navigationTitle("WebSocket Client")
        .toolbarTitleDisplayMode(.inlineLarge)
        .modifier {
          if #available(iOS 26.0, *) {
            $0
              .scrollEdgeEffectStyle(.soft, for: .top)
          } else {
            $0
          }
        }
        .onAppear {
          store.send(.onAppear)
        }
    }
    .fullScreenCover(
      item: $store.scope(\.destination, action: \.destination).connection,
      content: { store in
        ConnectionPage(store: store)
      },
    )
    .alert(
      $store.scope(\.destination, action: \.destination).alert,
      action: { action in
        if let action {
          store.send(.destination(.presented(.alert(action))))
        }
      },
    )
    .analyticsScreen(screenName: .form)
  }

  private var form: some View {
    GeometryReader { proxy in
      Form {
        adSection(proxy: proxy)
        firstSection
        secondSection
        thirdSection
      }
      .keyboardToolbar(
        isFocused: isFocused,
        closeAction: {
          isFocused = false
        },
      )
      .scrollDismissesKeyboard(.immediately)
    }
  }

  @ViewBuilder
  private func adSection(proxy: GeometryProxy) -> some View {
    if let adUnitID = store.adUnitID {
      let width = proxy.frame(in: .global).size.width - 20
      Section {
        adClient.make(adUnitID: adUnitID, size: .largeBanner)
          .frame(
            width: proxy.frame(in: .global).size.width - 20,
            height: width * 100 / 320,
          )
      }
      .listRowBackground(Color.clear)
      .listRowSeparator(.hidden)
    }
  }

  private var firstSection: some View {
    Section(
      content: {
        urlTextField
      },
      header: {
        Text(.formSectionFirstTitleHeader)
      }
    )
  }

  private var urlTextField: some View {
    HStack {
      Image(systemSymbol: .link)
        .foregroundColor(Color.blue)
      TextField(
        "wss://echo.websocket.org",
        text: .init(
          get: {
            store.url?.absoluteString ?? ""
          },
          set: {
            store.send(.urlChanged($0))
          }
        )
      )
      .focused($isFocused)
      .frame(maxHeight: .infinity)
    }
  }

  private var secondSection: some View {
    Section(
      content: {
        customHeaders
      },
      header: {
        Text(.formSectionSecondTitleHeader)
      }
    )
  }

  private var customHeaders: some View {
    Group {
      ForEach(0..<store.customHeaders.count, id: \.self) { index in
        customHeaderTextField(index: index)
      }
      .onDelete(
        perform: {
          store.send(.removeCustomHeader($0))
        }
      )
      addCustomHeaderButton
    }
  }

  private func customHeaderTextField(index: Int) -> some View {
    GeometryReader { proxy in
      HStack {
        TextField(
          String(localized: .formSectionSecondTitleName),
          text: .init(
            get: {
              store.customHeaders[safe: index]?.name ?? ""
            },
            set: {
              store.send(.customHeaderNameChanged(index, $0))
            }
          )
        )
        .focused($isFocused)
        .frame(maxWidth: proxy.frame(in: .local).width / 3, maxHeight: .infinity)
        Divider()
        TextField(
          String(localized: .formSectionSecondTitleValue),
          text: .init(
            get: {
              store.customHeaders[safe: index]?.value ?? ""
            },
            set: {
              store.send(.customHeaderValueChanged(index, $0))
            }
          )
        )
        .focused($isFocused)
        .frame(maxHeight: .infinity)
      }
    }
  }

  private var addCustomHeaderButton: some View {
    Button(
      action: {
        store.send(.addCustomHeader)
      },
      label: {
        Label(
          title: {
            Text(.formSectionSecondTitleAddButton)
              .offset(x: -12)
          },
          icon: {
            Image(systemSymbol: .plusSquareFill)
          }
        )
      }
    )
    .frame(maxWidth: .infinity)
  }

  private var thirdSection: some View {
    Section(
      content: {
        connectButton
      }
    )
  }

  private var connectButton: some View {
    Button(
      action: {
        store.send(.showBeforeAdsAlert)
      },
      label: {
        Text(.formSectionThirdTitleConnectButton)
          .frame(maxWidth: .infinity)
      }
    )
    .disabled(store.isConnectButtonDisable)
  }
}

@MainActor
private extension View {
  func keyboardToolbar(isFocused: Bool, closeAction: @escaping () -> Void) -> some View {
    self
      .safeAreaInset(edge: .bottom) {
        if #available(iOS 26.0, *), isFocused {
          HStack(alignment: .center, spacing: 0) {
            Spacer()
              .frame(maxWidth: .infinity)
            Button(action: closeAction) {
              Text(.formKeyboardTitleCloseButton)
                .bold()
                .foregroundStyle(Color(.label))
                .padding()
                .glassEffect()
            }
          }
          .padding(8)
        }
      }
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          if #available(iOS 26.0, *) {
            EmptyView()
          } else {
            Spacer()
            Button(action: closeAction) {
              Text(.formKeyboardTitleCloseButton)
                .bold()
            }
          }
        }
      }
  }
}

struct FormPage_Previews: PreviewProvider {
  static var previews: some View {
    FormPage(
      store: Store(
        initialState: FormReducer.State(
          url: URL(string: "wss://echo.websocket.org")!,
          isConnectButtonDisable: false
        )
      ) {
        FormReducer()
      }
    )
  }
}
