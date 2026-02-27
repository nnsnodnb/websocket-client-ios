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
      TabView {
        formPage()
        historyPage()
        infoPage()
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
      store: Store(
        initialState: FormReducer.State(),
        reducer: {
          FormReducer()
        },
      )
    )
    .tabItem(systemSymbol: .squareAndPencil, text: .tabBarTitleConnection)
  }

  private func historyPage() -> some View {
    HistoryListPage(
      store: Store(
        initialState: HistoryListReducer.State(),
        reducer: {
          HistoryListReducer()
        },
      )
    )
    .tabItem(systemSymbol: .trayFullFill, text: .tabBarTitleHistories)
  }

  private func infoPage() -> some View {
    InfoPage(
      store: Store(
        initialState: InfoReducer.State(),
        reducer: {
          InfoReducer()
        },
      )
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

struct RootPage_Previews: PreviewProvider {
  static var previews: some View {
    RootPage(
      store: Store(
        initialState: RootReducer.State(
          formAboveBannerAdUnitID: "ca-app-pub-3940256099942544/2435281174",
          migratedToSwiftData: true,
        ),
        reducer: {
          RootReducer()
        },
      )
    )
  }
}
