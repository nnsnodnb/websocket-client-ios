//
//  HistoryDetailPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/01.
//

import ComposableArchitecture
import FirebaseAnalyticsSwift
import SFSafeSymbols
import SwiftUI

struct HistoryDetailPage: View {
    let store: StoreOf<HistoryDetailReducer>

    // MARK: - State
    fileprivate struct ViewState: Equatable {
        let history: CDHistory
        let customHeaders: [CDCustomHeader]
        let messages: [CDMessage]
        let alert: AlertState<HistoryDetailReducer.Action>?
        let isShowCustomHeaderList: Bool

        // MARK: - Initialize
        init(state: HistoryDetailReducer.State) {
            self.history = state.history
            self.customHeaders = (state.history.customHeaders?.allObjects as? [CDCustomHeader]) ?? []
            self.messages = (state.history.messages?.allObjects as? [CDMessage]) ?? []
            self.alert = state.alert
            self.isShowCustomHeaderList = state.isShowCustomHeaderList
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            MessageListView(messages: viewStore.messages.compactMap { $0.text })
                .navigationTitle(viewStore.history.urlString ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(viewStore)
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.isShowCustomHeaderList,
                        send: { $0 ? .showCustomHeaderList : .dismissCustomHeaderList }
                    )
                ) {
                    CustomHeaderListPage(customHeaders: viewStore.customHeaders)
                        .presentationDetents([.fraction(0.2), .large])
                }
                .alert(store.scope(state: \.alert, action: { $0 }), dismiss: .alertDismissed)
        }
        .analyticsScreen(name: "history-detail-page")
    }
}

private extension View {
    func toolbar(_ viewStore: ViewStore<HistoryDetailPage.ViewState, HistoryDetailReducer.Action>) -> some View {
        toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(
                    content: {
                        if !viewStore.customHeaders.isEmpty {
                            Button(
                                action: {
                                    viewStore.send(.showCustomHeaderList, animation: .default)
                                },
                                label: {
                                    HStack {
                                        Text(L10n.HistoryDetail.Navibar.Menu.Title.checkCustomHeaders)
                                        Image(systemSymbol: .checkmarkMessageFill)
                                    }
                                }
                            )
                        }
                        Button(
                            role: .destructive,
                            action: {
                                viewStore.send(.checkDelete)
                            },
                            label: {
                                HStack {
                                    Text(L10n.HistoryDetail.Navibar.Menu.Title.delete)
                                    Image(systemSymbol: .trash)
                                }
                            }
                        )
                    },
                    label: {
                        Image(systemSymbol: .ellipsisCircle)
                            .foregroundColor(.blue)
                    }
                )
            }
        }
        .toolbarRole(.editor)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct HistoryDetailPage_Previews: PreviewProvider {
    static let context = DatabaseClient.previewValue.managedObjectContext()

    static var history: CDHistory {
        let history = CDHistory(context: context)
        history.id = UUID(0)
        history.urlString = "wss://echo.socket.events"
        let message = CDMessage(context: context)
        message.text = "Hello"
        history.addToMessages(message)
        history.isConnectionSuccess = true
        let customHeader = CDCustomHeader(context: context)
        customHeader.name = "name"
        customHeader.value = "value"
        history.addToCustomHeaders(customHeader)
        return history
    }

    static var previews: some View {
        NavigationStack {
            HistoryDetailPage(
                store: .init(
                    initialState: HistoryDetailReducer.State(
                        history: history
                    ),
                    reducer: HistoryDetailReducer()
                )
            )
        }
    }
}
