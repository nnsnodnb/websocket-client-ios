//
//  MessageListView.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/01.
//

import SwiftUI

struct MessageListView: View {
    let messages: [String]

    var body: some View {
        List(messages.reversed(), id: \.self) { message in
            Text(message)
        }
    }
}

struct MessageListView_Previews: PreviewProvider {
    static var previews: some View {
        MessageListView(messages: (1...10).map { "Message: \($0)" })
    }
}
