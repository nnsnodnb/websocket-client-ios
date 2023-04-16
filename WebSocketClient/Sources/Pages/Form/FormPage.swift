//
//  FormPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import SFSafeSymbols
import SwiftUI

struct FormPage: View {
    let store: StoreOf<FormReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack {
                form(viewStore)
                    .navigationTitle("WebSocket Client")
            }
            .fullScreenCover(
                isPresented: viewStore.binding(
                    get: { $0.connection != nil },
                    send: { $0 ? .connectionOpen : .connectionDismiss }
                ),
                content: {
                    IfLetStore(store.scope(state: \.connection, action: FormReducer.Action.connection)) { store in
                        ConnectionPage(store: store)
                    }
                }
            )
        })
    }

    private func form(_ viewStore: ViewStoreOf<FormReducer>) -> some View {
        Form {
            firstSection(viewStore)
            secondSection(viewStore)
            thirdSection(viewStore)
        }
    }

    private func firstSection(_ viewStore: ViewStoreOf<FormReducer>) -> some View {
        Section(
            content: {
                urlTextField(viewStore)
            },
            header: {
                Text("Connection setting")
            }
        )
    }

    private func urlTextField(_ viewStore: ViewStoreOf<FormReducer>) -> some View {
        HStack {
            Image(systemSymbol: .link)
                .foregroundColor(Color.blue)
            TextField(
                "wss://echo.websocket.events",
                text: viewStore.binding(
                    get: { $0.url?.absoluteString ?? "" },
                    send: FormReducer.Action.urlChanged
                )
            )
        }
    }

    private func secondSection(_ viewStore: ViewStoreOf<FormReducer>) -> some View {
        Section(
            content: {
                customHeaders(viewStore)
            },
            header: {
                Text("Custom Headers")
            }
        )
    }

    private func customHeaders(_ viewStore: ViewStoreOf<FormReducer>) -> some View {
        Group {
            ForEach(0..<viewStore.customHeaders.count, id: \.self) { index in
                customHeaderTextField(viewStore, index: index)
            }
            .onDelete(
                perform: {
                    viewStore.send(.removeCustomHeader($0), animation: .default)
                }
            )
            addCustomHeaderButton(viewStore)
        }
    }

    private func customHeaderTextField(_ viewStore: ViewStoreOf<FormReducer>, index: Int) -> some View {
        GeometryReader { proxy in
            HStack {
                TextField(
                    "Name",
                    text: viewStore.binding(
                        get: { $0.customHeaders[safe: index]?.name ?? "" },
                        send: { .customHeaderNameChanged(index, $0) }
                    )
                )
                .frame(maxWidth: proxy.frame(in: .local).width / 3)
                Divider()
                TextField(
                    "Value",
                    text: viewStore.binding(
                        get: { $0.customHeaders[safe: index]?.value ?? "" },
                        send: { .customHeaderValueChanged(index, $0) }
                    )
                )
            }
        }
    }

    private func addCustomHeaderButton(_ viewStore: ViewStoreOf<FormReducer>) -> some View {
        Button(
            action: {
                viewStore.send(.addCustomHeader, animation: .default)
            },
            label: {
                Label(
                    title: {
                        Text("Add")
                            .offset(x: -12)
                    },
                    icon: {
                        Image(systemSymbol: .plusSquareFill)
                    }
                )
            }
        )
        .frame(maxWidth: .infinity)
    }

    private func thirdSection(_ viewStore: ViewStoreOf<FormReducer>) -> some View {
        Section(
            content: {
                connectButton(viewStore)
            }
        )
    }

    private func connectButton(_ viewStore: ViewStoreOf<FormReducer>) -> some View {
        Button(
            action: {
                viewStore.send(.connect, animation: .default)
            },
            label: {
                Text("Connect")
                    .frame(maxWidth: .infinity)
            }
        )
        .disabled(viewStore.isConnectButtonDisable)
    }
}

struct FormPage_Previews: PreviewProvider {
    static var previews: some View {
        FormPage(
            store: Store(
                initialState: FormReducer.State(
                    url: URL(string: "wss://echo.websocket.events")!,
                    isConnectButtonDisable: false
                ),
                reducer: FormReducer()
            )
        )
    }
}