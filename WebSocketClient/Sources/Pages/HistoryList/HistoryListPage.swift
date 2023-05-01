//
//  HistoryListPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

import ComposableArchitecture
import SwiftUI

struct HistoryListPage: View {
    let store: StoreOf<HistoryListReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack {
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
        List(viewStore.histories) { history in
            NavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: \.selectionHistory?.value,
                        action: HistoryListReducer.Action.historyDetail
                    ),
                    then: { store in
                        HistoryDetailPage(store: store)
                    }
                ),
                tag: history,
                selection: viewStore.binding(
                    get: \.selectionHistory?.id,
                    send: HistoryListReducer.Action.setNavigation
                ),
                label: {
                    Text(history.urlString)
                }
            )
        }
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
