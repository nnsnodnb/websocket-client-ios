//
//  HistoryListPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

import ComposableArchitecture
import FirebaseAnalytics
import SFSafeSymbols
import SwiftUI

struct HistoryListPage: View {
  @Bindable var store: StoreOf<HistoryListReducer>

  var body: some View {
    NavigationStack(
      path: $store.paths.sending(\.navigationPathChanged)
    ) {
      content
        .navigationTitle(.historyListNavibarTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    .task {
      store.send(.fetch)
    }
    .analyticsScreen(name: "history-list-page")
  }

  @ViewBuilder private var content: some View {
    if store.histories.isEmpty {
      emptyView
    } else {
      list
    }
  }

  private var emptyView: some View {
    ContentUnavailableView(
      label: {
        VStack(spacing: 16) {
          Image(systemSymbol: .noteText)
            .resizable()
            .frame(width: 56, height: 56)
          Text(.historyListContentTitleEmpty)
            .font(.title2)
            .fontWeight(.bold)
        }
        .foregroundStyle(.orange)
      }
    )
    .background {
      Color(UIColor.systemGroupedBackground)
    }
  }

  private var list: some View {
    List {
      ForEach(store.histories) { history in
        row(history: history)
      }
      .onDelete {
        store.send(.deleteHistory($0))
      }
    }
    .navigationDestination(
      for: HistoryListReducer.State.Destination.self,
      destination: { destination in
        switch destination {
        case .historyDetail:
          if let store = store.scope(state: \.selectionHistory?.value, action: \.historyDetail) {
            HistoryDetailPage(store: store)
          }
        }
      }
    )
  }

  private func row(history: HistoryEntity) -> some View {
    HStack {
      Button(
        action: {
          store.send(.setNavigation(history))
        },
        label: {
          Text(history.url.absoluteString)
            .foregroundColor(.primary)
        }
      )
      Spacer()
      Image(systemSymbol: .chevronRight)
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(.secondary)
        .opacity(0.5)
    }
  }
}

struct HistoryListPage_Previews: PreviewProvider {
  static var history: HistoryEntity {
    return .init(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: false,
      createdAt: .init()
    )
  }

  static var previews: some View {
    HistoryListPage(
      store: Store(
        initialState: HistoryListReducer.State(
          histories: [history]
        )
      ) {
        HistoryListReducer()
      }
    )
  }
}
