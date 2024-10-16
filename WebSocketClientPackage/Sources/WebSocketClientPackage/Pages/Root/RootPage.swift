//
//  RootPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import SFSafeSymbols
import SwiftUI

@MainActor
public struct RootPage: View {
    let store: StoreOf<RootReducer>

    public var body: some View {
        WithPerceptionTracking {
            TabView {
                formPage()
                historyPage()
                infoPage()
            }
        }
    }

    private func formPage() -> some View {
        FormPage(
            store: Store(initialState: FormReducer.State()) {
                FormReducer()
            }
        )
        .tabItem(systemSymbol: .squareAndPencil, text: L10n.TabBar.Title.connection)
    }

    private func historyPage() -> some View {
        HistoryListPage(
            store: Store(initialState: HistoryListReducer.State()) {
                HistoryListReducer()
            }
        )
        .tabItem(systemSymbol: .trayFullFill, text: L10n.TabBar.Title.histories)
    }

    private func infoPage() -> some View {
        InfoPage(
            store: Store(initialState: InfoReducer.State()) {
                InfoReducer()
            }
        )
        .tabItem(systemSymbol: .infoCircleFill, text: L10n.TabBar.Title.info)
    }

    // MARK: - Initialize
    public init(store: StoreOf<RootReducer>) {
        self.store = store
    }
}

@MainActor
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
            store: Store(initialState: RootReducer.State()) {
                RootReducer()
            }
        )
    }
}
