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
        SwitchStore(store) {
            CaseLet(state: /RootReducer.State.form, action: RootReducer.Action.form) { store in
                TabView {
                    formPage(store)
                    historyPage()
                    infoPage()
                }
            }
        }
    }

    private func formPage(_ store: StoreOf<FormReducer>) -> some View {
        FormPage(store: store)
            .tabItem(systemSymbol: .squareAndPencil, text: "Connection")
    }

    private func historyPage() -> some View {
        Text("History")
            .tabItem(systemSymbol: .trayFullFill, text: "History")
    }

    private func infoPage() -> some View {
        Text("Info")
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
                initialState: RootReducer.State.form(.init()),
                reducer: RootReducer()
            )
        )
    }
}
