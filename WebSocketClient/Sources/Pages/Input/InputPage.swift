//
//  InputPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import SFSafeSymbols
import SwiftUI

struct InputPage: View {
    let store: StoreOf<InputReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack {
                form(viewStore)
                    .navigationTitle("WebSocket Client")
            }
        })
    }

    private func form(_ viewStore: ViewStoreOf<InputReducer>) -> some View {
        Form {
            Section(
                content: {
                    urlTextField(viewStore)
                },
                header: {
                    Text("Connection setting")
                }
            )
            Section(
                content: {
                    customHeaders(viewStore)
                },
                header: {
                    Text("Custom Headers")
                }
            )
            Section(
                content: {
                    connectButton(viewStore)
                }
            )
        }
    }

    private func urlTextField(_ viewStore: ViewStoreOf<InputReducer>) -> some View {
        HStack {
            Image(systemSymbol: .link)
                .foregroundColor(Color.blue)
            TextField(
                "wss://echo.websocket.events",
                text: viewStore.binding(
                    get: { $0.url?.absoluteString ?? "" },
                    send: InputReducer.Action.urlChanged
                )
            )
        }
    }

    private func customHeaders(_ viewStore: ViewStoreOf<InputReducer>) -> some View {
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

    private func customHeaderTextField(_ viewStore: ViewStoreOf<InputReducer>, index: Int) -> some View {
        GeometryReader { proxy in
            HStack {
                TextField(
                    "Name",
                    text: viewStore.binding(
                        get: { $0.customHeaders[index]?.name ?? "" },
                        send: { .customHeaderNameChanged(index, $0) }
                    )
                )
                .frame(maxWidth: proxy.frame(in: .local).width / 3)
                Divider()
                TextField(
                    "Value",
                    text: viewStore.binding(
                        get: { $0.customHeaders[index]?.value ?? "" },
                        send: { .customHeaderValueChanged(index, $0) }
                    )
                )
            }
        }
    }

    private func addCustomHeaderButton(_ viewStore: ViewStoreOf<InputReducer>) -> some View {
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

    private func connectButton(_ viewStore: ViewStoreOf<InputReducer>) -> some View {
        Button(
            action: {
                viewStore.send(.connect)
            },
            label: {
                Text("Connect")
                    .frame(maxWidth: .infinity)
            }
        )
        .disabled(viewStore.isConnectButtonDisable)
    }
}

struct InputPage_Previews: PreviewProvider {
    static let url: URL? = URL(string: "wss://echo.websocket.events")

    static var previews: some View {
        InputPage(
            store: Store(
                initialState: InputReducer.State(url: url),
                reducer: InputReducer()
            )
        )
    }
}
