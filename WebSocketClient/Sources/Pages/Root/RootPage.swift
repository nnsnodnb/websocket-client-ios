//
//  RootPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import SwiftUI

struct RootPage: View {
    let store: StoreOf<RootReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            ContentView()
        })
    }
}

struct RootPage_Previews: PreviewProvider {
    static var previews: some View {
        RootPage(
            store: Store(
                initialState: RootReducer.State.default,
                reducer: RootReducer()
            )
        )
    }
}
