//
//  RootPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import SFSafeSymbols
import SwiftUI

public struct RootPage: View {
  let store: StoreOf<RootReducer>

  public var body: some View {
    if store.migratedToSwiftData {
      if let store = store.scope(state: \.consent, action: \.consent) {
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
    FormPage(
      store: store.scope(state: \.form, action: \.form),
    )
    .tabItem(systemSymbol: .squareAndPencil, text: .tabBarTitleConnection)
  }

  private func historyPage() -> some View {
    HistoryListPage(
      store: store.scope(state: \.historyList, action: \.historyList),
    )
    .tabItem(systemSymbol: .trayFullFill, text: .tabBarTitleHistories)
  }

  private func infoPage() -> some View {
    InfoPage(
      store: store.scope(state: \.info, action: \.info),
    )
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
      },
    )
  )
}
