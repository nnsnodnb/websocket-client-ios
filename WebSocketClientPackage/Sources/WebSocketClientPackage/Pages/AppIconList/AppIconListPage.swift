//
//  AppIconListPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/04.
//

import ComposableArchitecture
import SwiftUI

struct AppIconListPage: View {
    let store: StoreOf<AppIconListReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            List(viewStore.appIcons, id: \.displayName) {
                appRow(viewStore, appIcon: $0)
            }
            .navigationTitle(L10n.AppIconList.Navibar.title)
            .navigationBarTitleDisplayMode(.inline)
        })
    }

    private func appRow(
        _ viewStore: ViewStoreOf<AppIconListReducer>,
        appIcon: AppIconListReducer.State.AppIcon
    ) -> some View {
        Button(
            action: {
                viewStore.send(.appIconChanged(appIcon))
            },
            label: {
                HStack(spacing: 12) {
                    appIcon.image
                        .resizable()
                        .frame(width: 54, height: 54)
                        .cornerRadius(12)
                    Text(appIcon.displayName)
                        .foregroundColor(.primary)
                }
            }
        )
    }
}

struct AppIconListPage_Previews: PreviewProvider {
    static var previews: some View {
        AppIconListPage(
            store: Store(initialState: AppIconListReducer.State()) {
                AppIconListReducer()
            }
        )
    }
}
