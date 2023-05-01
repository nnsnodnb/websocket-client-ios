//
//  HistoryDetailPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/01.
//

import ComposableArchitecture
import SwiftUI

struct HistoryDetailPage: View {
    let store: StoreOf<HistoryDetailReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            Text(viewStore.history.id)
        })
    }
}

struct HistoryDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        HistoryDetailPage(
            store: .init(
                initialState: HistoryDetailReducer.State(history: .init()),
                reducer: HistoryDetailReducer()
            )
        )
    }
}
