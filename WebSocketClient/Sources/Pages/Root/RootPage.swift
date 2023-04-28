//
//  RootPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import SFSafeSymbols
import SwiftUI

struct RootPage: View {
    let store: StoreOf<RootReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { _ in
            TabView {
                formPage()
                historyPage()
                infoPage()
            }
        })
    }

    private func formPage() -> some View {
        FormPage(
            store: Store(
                initialState: FormReducer.State(url: URL(string: "https://echo.websocket.events"), isConnectButtonDisable: false),
//                initialState: FormReducer.State(),
                reducer: FormReducer()
            )
        )
        .tabItem(systemSymbol: .squareAndPencil, text: "Connection")
    }

    private func historyPage() -> some View {
        HistoryListPage(
            store: Store(
                initialState: HistoryListReducer.State(),
                reducer: HistoryListReducer()
            )
        )
        .tabItem(systemSymbol: .trayFullFill, text: "History")
    }

    private func infoPage() -> some View {
        InfoPage(
            store: Store(
                initialState: InfoReducer.State(),
                reducer: InfoReducer()
            )
        )
        .tabItem(systemSymbol: .infoCircleFill, text: "Info")
    }
}

private extension View {
    func tabItem(systemSymbol: SFSymbol, text: String) -> some View {
        tabItem {
            VStack {
                Image(systemSymbol: systemSymbol)
                Text(text)
            }
        }
    }
}

struct RootPage_Previews: PreviewProvider {
    static var previews: some View {
        RootPage(
            store: Store(
                initialState: RootReducer.State(),
                reducer: RootReducer()
            )
        )
    }
}
