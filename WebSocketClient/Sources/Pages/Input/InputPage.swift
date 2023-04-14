//
//  InputPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
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
                    Text("connection url")
                }
            )
        }
    }

    private func urlTextField(_ viewStore: ViewStoreOf<InputReducer>) -> some View {
        TextField(
            "wss://example.com",
            text: viewStore.binding(
                get: { $0.url?.absoluteString ?? "" },
                send: InputReducer.Action.urlChanged
            )
        )
    }
}

struct InputPage_Previews: PreviewProvider {
    static let url = URL(string: "wss://echo.websocket.org")!

    static var previews: some View {
        InputPage(
            store: Store(
                initialState: InputReducer.State(url: url),
                reducer: InputReducer()
            )
        )
    }
}
