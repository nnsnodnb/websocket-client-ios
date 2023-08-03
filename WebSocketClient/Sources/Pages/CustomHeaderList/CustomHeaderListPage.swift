//
//  CustomHeaderListPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
import FirebaseAnalyticsSwift
import SwiftUI

struct CustomHeaderListPage: View {
    let customHeaders: [CustomHeaderEntity]

    var body: some View {
        NavigationStack {
            list
                .navigationTitle(L10n.CustomHeaderList.Navibar.title)
                .navigationBarTitleDisplayMode(.inline)
        }
        .analyticsScreen(name: "custom-header-list-page")
    }

    private var list: some View {
        List {
            ForEach(customHeaders, id: \.self) { customHeader in
                section(for: customHeader)
            }
        }
    }

    @ViewBuilder
    private func section(for customHeader: CustomHeaderEntity) -> some View {
        Section {
            VStack(alignment: .leading) {
                Text(customHeader.name)
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                Text(customHeader.value)
            }
        }
    }
}

struct CustomHeaderListPage_Previews: PreviewProvider {
    static var customHeaders: [CustomHeaderEntity] {
        return (1...3).map { index in
            var customHeader = CustomHeaderEntity(id: .init(index))
            customHeader.setName("name-\(index)")
            customHeader.setValue("value-\(index)")
            return customHeader
        }
    }

    static var previews: some View {
        CustomHeaderListPage(
            customHeaders: customHeaders
        )
    }
}
