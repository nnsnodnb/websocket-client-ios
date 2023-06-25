//
//  ConnectionPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/17.
//

import ComposableArchitecture
import FirebaseAnalyticsSwift
import SwiftUI

struct ConnectionPage: View {
    let store: StoreOf<ConnectionReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack {
                content(viewStore)
                    .navigationTitle(viewStore.url.absoluteString)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(viewStore)
            }
            .alert(store.scope(state: \.alert, action: { $0 }), dismiss: .alertDismissed)
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isShowCustomHeaderList,
                    send: { $0 ? .showCustomHeaderList : .dismissCustomHeaderList }
                )
            ) {
                CustomHeaderListPage(customHeaders: viewStore.customHeaders)
                    .presentationDetents([.fraction(0.2), .large])
            }
            .task {
                viewStore.send(.start)
            }
        })
        .analyticsScreen(name: "connection-page")
    }

    private func content(_ viewStore: ViewStoreOf<ConnectionReducer>) -> some View {
        VStack(spacing: 0) {
            messageTextField(viewStore)
            receivedMessageList(viewStore)
        }
    }

    private func messageTextField(_ viewStore: ViewStoreOf<ConnectionReducer>) -> some View {
        HStack {
            TextField(
                L10n.Connection.TextField.placeholder,
                text: viewStore.binding(
                    get: \.message,
                    send: ConnectionReducer.Action.messageChanged
                )
            )
            .frame(height: 44)
            Button(
                action: {
                    viewStore.send(.sendMessage)
                },
                label: {
                    Text(L10n.Connection.Title.sendButton)
                        .bold()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            )
            .disabled(viewStore.isSendButtonDisabled)
            .frame(width: 80)
        }
        .padding(.horizontal)
        .frame(height: 44)
        .backgroundStyle(Color.clear)
    }

    private func receivedMessageList(_ viewStore: ViewStoreOf<ConnectionReducer>) -> some View {
        MessageListView(messages: viewStore.receivedMessages)
    }
}

private extension View {
    func toolbar(_ viewStore: ViewStoreOf<ConnectionReducer>) -> some View {
        toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        viewStore.send(.close, animation: .default)
                    },
                    label: {
                        Image(systemSymbol: .xmark)
                            .resizable()
                            .frame(maxWidth: 44, maxHeight: 44)
                            .fontWeight(.medium)
                    }
                )
            }
            if !viewStore.customHeaders.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(
                        content: {
                            Button(
                                action: {
                                    viewStore.send(.showCustomHeaderList, animation: .default)
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
    static let context = DatabaseClient.previewValue.managedObjectContext()

    static var previews: some View {
        Group {
            ConnectionPage(
                store: .init(
                    initialState: ConnectionReducer.State(
                        url: URL(string: "wss://echo.websocket.events")!,
                        history: .init(context: context)
                    ),
                    reducer: ConnectionReducer()
                )
            )
            .previewDisplayName("Empty custom header")
            ConnectionPage(
                store: .init(
                    initialState: ConnectionReducer.State(
                        url: URL(string: "wss://echo.websocket.events")!,
                        history: {
                            let history = CDHistory(context: context)
                            let customHeader = CDCustomHeader(context: context)
                            customHeader.name = "name"
                            customHeader.value = "value"
                            customHeader.history = history
                            history.addToCustomHeaders(customHeader)
                            return history
                        }()
                    ),
                    reducer: ConnectionReducer()
                )
            )
            .previewDisplayName("Exist custom headers")
        }
    }
}
