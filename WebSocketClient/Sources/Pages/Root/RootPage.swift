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
        SwitchStore(store) {
            CaseLet(state: /RootReducer.State.input, action: RootReducer.Action.input) { store in
                InputPage(store: store)
            }
        }
    }
}

struct RootPage_Previews: PreviewProvider {
    static var previews: some View {
        RootPage(
            store: Store(
                initialState: RootReducer.State.input(.init()),
                reducer: RootReducer()
            )
        )
    }
}
