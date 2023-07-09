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
    let customHeaders: [CDCustomHeader]

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
    private func section(for customHeader: CDCustomHeader) -> some View {
        if let name = customHeader.name, let value = customHeader.value {
            Section {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    Text(value)
                }
            }
        }
    }
}

struct CustomHeaderListPage_Previews: PreviewProvider {
    static let context = DatabaseClient.previewValue.managedObjectContext()

    static var customHeaders: [CDCustomHeader] {
        return (1...3).map { index in
            let customHeader = CDCustomHeader(context: context)
            customHeader.name = "name-\(index)"
            customHeader.value = "value \(index)"
            return customHeader
        }
    }

    static var previews: some View {
        CustomHeaderListPage(
            customHeaders: customHeaders
        )
    }
}
