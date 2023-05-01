//
//  HistoryListPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

import ComposableArchitecture
import SFSafeSymbols
import SwiftUI

struct HistoryListPage: View {
    let store: StoreOf<HistoryListReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack(
                path: viewStore.binding(
                    get: \.paths,
                    send: HistoryListReducer.Action.navigationPathChanged
                )
            ) {
                content(viewStore)
                    .navigationTitle("Histories")
            }
            .task {
                viewStore.send(.fetch)
            }
        })
    }

    @ViewBuilder
    private func content(_ viewStore: ViewStoreOf<HistoryListReducer>) -> some View {
        if viewStore.histories.isEmpty {
            emptyView
        } else {
            list(viewStore)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemSymbol: .noteText)
                .resizable()
                .frame(width: 56, height: 56)
            Text("No history")
                .font(.title2)
                .fontWeight(.bold)
        }
        .foregroundColor(.orange)
    }

    private func list(_ viewStore: ViewStoreOf<HistoryListReducer>) -> some View {
        List {
            ForEach(viewStore.histories) { history in
                row(viewStore, for: history)
            }
            .onDelete {
                viewStore.send(.deleteHistory($0), animation: .default)
            }
        }
    }

    private func row(_ viewStore: ViewStoreOf<HistoryListReducer>, for history: History) -> some View {
        HStack {
            Button(
                action: {
                    viewStore.send(.setNavigation(history))
                },
                label: {
                    Text(history.urlString)
                        .foregroundColor(.primary)
                }
            )
            Spacer()
            Image(systemSymbol: .chevronRight)
                .foregroundColor(.secondary)
                .frame(width: 12, height: 12)
        }
        .navigationDestination(
            for: HistoryListReducer.State.Destination.self,
            destination: { destination in
                switch destination {
                case .historyDetail:
                    IfLetStore(
                        store.scope(
                            state: \.selectionHistory?.value,
                            action: HistoryListReducer.Action.historyDetail
                        ),
                        then: { store in
                            HistoryDetailPage(store: store)
                        }
                    )
                }
            }
        )
    }
}

struct HistoryListPage_Previews: PreviewProvider {
    static var previews: some View {
        HistoryListPage(
            store: Store(
                initialState: HistoryListReducer.State(
                    histories: [.init(urlString: "wss://echo.websocket.events")]
                ),
                reducer: HistoryListReducer()
            )
        )
    }
}
