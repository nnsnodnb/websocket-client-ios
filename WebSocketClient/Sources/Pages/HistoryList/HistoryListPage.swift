//
//  HistoryListPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

import ComposableArchitecture
import SwiftUI

struct HistoryListPage: View {
    let store: StoreOf<HistoryListReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            Text("Hello")
        })
    }
}

struct HistoryListPage_Previews: PreviewProvider {
    static var previews: some View {
        HistoryListPage(
            store: Store(
                initialState: HistoryListReducer.State(),
                reducer: HistoryListReducer()
            )
        )
    }
}
