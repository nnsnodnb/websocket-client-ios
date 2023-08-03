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

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            MessageListView(messages: viewStore.history.messages.map { $0.text })
                .navigationTitle(viewStore.history.url.absoluteString)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(viewStore)
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.isShowCustomHeaderList,
                        send: { $0 ? .showCustomHeaderList : .dismissCustomHeaderList }
                    )
                ) {
                    CustomHeaderListPage(customHeaders: viewStore.history.customHeaders)
                        .presentationDetents([.fraction(0.2), .large])
                }
                .alert(store.scope(state: \.alert, action: { $0 }), dismiss: .alertDismissed)
        })
        .analyticsScreen(name: "history-detail-page")
    }
}

private extension View {
    func toolbar(_ viewStore: ViewStoreOf<HistoryDetailReducer>) -> some View {
        toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(
                    content: {
                        if !viewStore.history.customHeaders.isEmpty {
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
    static var history: HistoryEntity {
        var customHeader = CustomHeaderEntity(id: .init(0))
        customHeader.setName("name")
        customHeader.setValue("value")
        let message = MessageEntity(id: .init(0), text: "Hello", createdAt: .init())
        let history = HistoryEntity(
            id: .init(0),
            url: URL(string: "wss://echo.socket.events")!,
            customHeaders: [customHeader],
            messages: [message],
            isConnectionSuccess: true,
            createdAt: .init()
        )
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
