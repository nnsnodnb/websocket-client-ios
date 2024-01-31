//
//  HistoryListPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

import ComposableArchitecture
import FirebaseAnalytics
import Perception
import SFSafeSymbols
import SwiftUI

struct HistoryListPage: View {
    @Perception.Bindable var store: StoreOf<HistoryListReducer>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack(
                path: $store.paths.sending(\.navigationPathChanged)
            ) {
                content
                    .navigationTitle(L10n.HistoryList.Navibar.title)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .task {
                store.send(.fetch)
            }
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
        VStack(spacing: 16) {
            Image(systemSymbol: .noteText)
                .resizable()
                .frame(width: 56, height: 56)
            Text(L10n.HistoryList.Content.Title.empty)
                .font(.title2)
                .fontWeight(.bold)
        }
        .foregroundColor(.orange)
    }

    private var list: some View {
        List {
            ForEach(store.histories) { history in
                row(history: history)
            }
            .onDelete {
                store.send(.deleteHistory($0), animation: .default)
            }
        }
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
}

struct HistoryListPage_Previews: PreviewProvider {
    static var history: HistoryEntity {
        return .init(
            id: .init(0),
            url: URL(string: "wss://echo.websocket.events")!,
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
