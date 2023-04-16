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
            CaseLet(state: /RootReducer.State.form, action: RootReducer.Action.form) { store in
                FormPage(store: store)
            }
        }
    }
}

struct RootPage_Previews: PreviewProvider {
    static var previews: some View {
        RootPage(
            store: Store(
                initialState: RootReducer.State.form(.init()),
                reducer: RootReducer()
            )
        )
    }
}
