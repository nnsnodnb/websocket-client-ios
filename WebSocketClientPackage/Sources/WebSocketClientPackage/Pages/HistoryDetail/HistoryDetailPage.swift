//
//  HistoryDetailPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/01.
//

import ComposableArchitecture
import FirebaseAnalytics
import Perception
import SFSafeSymbols
import SwiftUI

struct HistoryDetailPage: View {
    @Perception.Bindable var store: StoreOf<HistoryDetailReducer>

    var body: some View {
        WithPerceptionTracking {
            MessageListView(messages: store.history.messages.map { $0.text })
                .navigationTitle(store.history.url.absoluteString)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(store: store)
                .sheet(
                    isPresented: $store.isShowCustomHeaderList.sending(
                        \.showedCustomHeaderList
                    ),
                    content: {
                        CustomHeaderListPage(customHeaders: store.history.customHeaders)
                            .presentationDetents([.fraction(0.2), .large])
                    }
                )
                .alert($store.scope(state: \.alert, action: \.alert))
        }
        .analyticsScreen(name: "history-detail-page")
    }
}

private extension View {
    func toolbar(store: StoreOf<HistoryDetailReducer>) -> some View {
        toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(
                    content: {
                        if !store.history.customHeaders.isEmpty {
                            Button(
                                action: {
                                    store.send(.showedCustomHeaderList(true), animation: .default)
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
                                store.send(.checkDelete)
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
                    )
                ) {
                    HistoryDetailReducer()
                }
            )
        }
    }
}
