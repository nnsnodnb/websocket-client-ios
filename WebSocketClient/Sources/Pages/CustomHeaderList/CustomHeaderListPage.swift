//
//  CustomHeaderListPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
import SwiftUI

struct CustomHeaderListPage: View {
    let customHeaders: [CustomHeader]

    var body: some View {
        list
            .navigationTitle("Additional headers")
            .navigationBarTitleDisplayMode(.inline)
    }

    private var list: some View {
        List {
            ForEach(customHeaders, id: \.self) { customHeader in
                section(for: customHeader)
            }
        }
    }

    private func section(for customHeader: CustomHeader) -> some View {
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
    static var previews: some View {
        CustomHeaderListPage(
            customHeaders: [
                .init(name: "name-1", value: "value 1"),
                .init(name: "name-2", value: "value 2"),
                .init(name: "name-3", value: "value 3")
            ]
        )
    }
}
