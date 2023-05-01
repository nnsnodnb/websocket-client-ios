//
//  ConnectionPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/17.
//

import ComposableArchitecture
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
            .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
            .task {
                viewStore.send(.start)
            }
        })
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
                "Message",
                text: viewStore.binding(
                    get: \.message,
                    send: ConnectionReducer.Action.messageChanged
                )
            )
            .padding(.vertical, 16)
            Button(
                action: {
                    viewStore.send(.sendMessage)
                },
                label: {
                    Text("Send")
                        .bold()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            )
            .disabled(viewStore.isSendButtonDisabled)
            .frame(width: 80, height: 44)
        }
        .padding(.horizontal)
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
        }
    }
}

struct ConnectionPage_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionPage(
            store: .init(
                initialState: ConnectionReducer.State(
                    url: URL(string: "wss://echo.websocket.events")!,
                    history: .init()
                ),
                reducer: ConnectionReducer()
            )
        )
    }
}
