//
//  AppIconListPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/04.
//

import ComposableArchitecture
import SwiftUI

@MainActor
struct AppIconListPage: View {
    let store: StoreOf<AppIconListReducer>

    var body: some View {
        WithPerceptionTracking {
            List(store.appIcons, id: \.displayName) {
                appRow(appIcon: $0)
            }
            .navigationTitle(L10n.AppIconList.Navibar.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func appRow(appIcon: AppIconListReducer.State.AppIcon) -> some View {
        Button(
            action: {
                store.send(.appIconChanged(appIcon))
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
