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
    TabView {
      formPage()
      historyPage()
      infoPage()
    }
  }

  private func formPage() -> some View {
    FormPage(
      store: Store(initialState: FormReducer.State()) {
        FormReducer()
      }
    )
    .tabItem(systemSymbol: .squareAndPencil, text: .tabBarTitleConnection)
  }

  private func historyPage() -> some View {
    HistoryListPage(
      store: Store(initialState: HistoryListReducer.State()) {
        HistoryListReducer()
      }
    )
    .tabItem(systemSymbol: .trayFullFill, text: .tabBarTitleHistories)
  }

  private func infoPage() -> some View {
    InfoPage(
      store: Store(initialState: InfoReducer.State()) {
        InfoReducer()
      }
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
      store: Store(initialState: RootReducer.State()) {
        RootReducer()
      }
    )
  }
}
