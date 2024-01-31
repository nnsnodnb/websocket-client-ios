//
//  ConnectionPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/17.
//

import ComposableArchitecture
import FirebaseAnalytics
import Perception
import SwiftUI

struct ConnectionPage: View {
    @Perception.Bindable var store: StoreOf<ConnectionReducer>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                content
                    .navigationTitle(store.url.absoluteString)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(store: store)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .sheet(
                isPresented: $store.isShowCustomHeaderList.sending(\.showedCustomHeaderList),
                content: {
                    CustomHeaderListPage(customHeaders: store.customHeaders)
                        .presentationDetents([.fraction(0.2), .large])
                }
            )
            .task {
                store.send(.start)
            }
        }
        .analyticsScreen(name: "connection-page")
    }

    private var content: some View {
        VStack(spacing: 0) {
            messageTextField
            receivedMessageList
        }
    }

    private var messageTextField: some View {
        HStack {
            TextField(
                L10n.Connection.TextField.placeholder,
                text: $store.message.sending(\.messageChanged)
            )
            .frame(height: 44)
            Button(
                action: {
                    store.send(.sendMessage)
                },
                label: {
                    Text(L10n.Connection.Title.sendButton)
                        .bold()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            )
            .disabled(store.isSendButtonDisabled)
            .frame(width: 80)
        }
        .padding(.horizontal)
        .frame(height: 44)
        .backgroundStyle(Color.clear)
    }

    private var receivedMessageList: some View {
        MessageListView(messages: store.receivedMessages)
    }
}

@MainActor
private extension View {
    func toolbar(store: StoreOf<ConnectionReducer>) -> some View {
        toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        store.send(.close, animation: .default)
                    },
                    label: {
                        Image(systemSymbol: .xmark)
                            .resizable()
                            .frame(maxWidth: 44, maxHeight: 44)
                            .fontWeight(.medium)
                    }
                )
            }
            if !store.customHeaders.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(
                        content: {
                            Button(
                                action: {
                                    store.send(.showedCustomHeaderList(true), animation: .default)
                                },
                                label: {
                                    HStack {
                                        Text(L10n.Connection.Navibar.Menu.Title.checkCustomHeaders)
                                        Image(systemSymbol: .checkmarkMessageFill)
                                    }
                                }
                            )
                        },
                        label: {
                            Image(systemSymbol: .ellipsisCircle)
                        }
                    )
                }
            }
        }
    }
}

struct ConnectionPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConnectionPage(
                store: .init(
                    initialState: ConnectionReducer.State(
                        url: URL(string: "wss://echo.websocket.events")!,
                        history: .init(
                            id: .init(0),
                            url: URL(string: "wss://echo.websocket.events")!,
                            customHeaders: [],
                            messages: [],
                            isConnectionSuccess: false,
                            createdAt: .init()
                        )
                    )
                ) {
                    ConnectionReducer()
                }
            )
            .previewDisplayName("Empty custom header")
            ConnectionPage(
                store: .init(
                    initialState: ConnectionReducer.State(
                        url: URL(string: "wss://echo.websocket.events")!,
                        history: {
                            var customHeader = CustomHeaderEntity(id: .init(1))
                            customHeader.setName("name")
                            customHeader.setValue("value")
                            return .init(
                                id: .init(1),
                                url: URL(string: "wss://echo.websocket.events")!,
                                customHeaders: [customHeader],
                                messages: [],
                                isConnectionSuccess: false,
                                createdAt: .init()
                            )
                        }()
                    )
                ) {
                    ConnectionReducer()
                }
            )
            .previewDisplayName("Exist custom headers")
        }
    }
}
