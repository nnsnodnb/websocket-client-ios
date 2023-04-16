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
                Text("Hello, World!")
                    .navigationTitle(viewStore.url.absoluteString)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(viewStore)
            }
        })
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
                    customHeaders: []
                ),
                reducer: ConnectionReducer()
            )
        )
    }
}
