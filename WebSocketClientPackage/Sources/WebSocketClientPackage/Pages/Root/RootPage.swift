//
//  RootPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import SFSafeSymbols
import SwiftUI

@Reducer
public struct RootReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    public var consent: ConsentReducer.State? = .init()
    public var form: FormReducer.State = .init()
    public var historyList: HistoryListReducer.State = .init()
    public var info: InfoReducer.State = .init()
    public var migratedToSwiftData = false

    // MARK: - Initialize
    public init(migratedToSwiftData: Bool = false) {
      self.migratedToSwiftData = migratedToSwiftData
    }
  }

  // MARK: - Action
  public enum Action {
    case migrateDatabase
    case showConsent
    case consent(ConsentReducer.Action)
    case form(FormReducer.Action)
    case historyList(HistoryListReducer.Action)
    case info(InfoReducer.Action)
  }

  @Dependency(\.database)
  private var database

  public var body: some ReducerOf<Self> {
    Scope(\.form, action: \.form) {
      FormReducer()
    }
    Scope(\.historyList, action: \.historyList) {
      HistoryListReducer()
    }
    Scope(\.info, action: \.info) {
      InfoReducer()
    }
    Reduce { state, action in
      switch action {
      case .migrateDatabase:
        guard !state.migratedToSwiftData else { return .none }
        return .run { send in
          try await database.migrateCoreDataToSwiftData()
          await send(.showConsent)
        }
      case .showConsent:
        state.consent = .init()
        state.migratedToSwiftData = true
        return .none
      case .consent(.delegate(.completedConsent)):
        state.consent = nil
        return .none
      case .consent:
        return .none
      case .form:
        return .none
      case .historyList:
        return .none
      case .info:
        return .none
      }
    }
    .ifLet(\.consent, action: \.consent) {
      ConsentReducer()
    }
  }

  // MARK: - Initialize
  public init() {
  }
}

public struct RootPage: View {
  let store: StoreOf<RootReducer>

  public var body: some View {
    if store.migratedToSwiftData {
      if let store = store.scope(\.consent, action: \.consent) {
        ConsentPage(store: store)
      } else {
        TabView {
          formPage()
          historyPage()
          infoPage()
        }
      }
    } else {
      ProgressView()
        .progressViewStyle(.circular)
        .scaleEffect(2)
        .onAppear {
          store.send(.migrateDatabase)
        }
    }
  }

  private func formPage() -> some View {
    FormPage(store: store.scope(\.form, action: \.form))
      .tabItem(systemSymbol: .squareAndPencil, text: .tabBarTitleConnection)
  }

  private func historyPage() -> some View {
    HistoryListPage(store: store.scope(\.historyList, action: \.historyList))
      .tabItem(systemSymbol: .trayFullFill, text: .tabBarTitleHistories)
  }

  private func infoPage() -> some View {
    InfoPage(store: store.scope(\.info, action: \.info))
      .tabItem(systemSymbol: .infoCircleFill, text: .tabBarTitleInfo)
  }

  // MARK: - Initialize
  public init(store: StoreOf<RootReducer>) {
    self.store = store
  }
}

@MainActor
private extension View {
  func tabItem(systemSymbol: SFSymbol, text: LocalizedStringResource) -> some View {
    tabItem {
      VStack {
        Image(systemSymbol: systemSymbol)
        Text(text)
      }
    }
  }
}

#Preview {
  RootPage(
    store: Store(
      initialState: RootReducer.State(
        migratedToSwiftData: true,
      ),
      reducer: {
        RootReducer()
      },
      withDependencies: {
        $0.adUnitID.formAboveBannerAdUnitID = { "ca-app-pub-3940256099942544/2435281174" }
        $0.adUnitID.webSocketConnectionRewardInterstitialAdUnitID = { "ca-app-pub-3940256099942544/6978759866" }
      },
    )
  )
}
