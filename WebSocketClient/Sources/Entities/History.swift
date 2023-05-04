//
//  History.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/19.
//

import Foundation
import Unrealm

struct History: Realmable, Identifiable, Hashable {
    // MARK: - Properties
    var id: String = ""
    var urlString: String = ""
    var messages: [Message] = []
    var isConnectionSuccess = false
    var customHeaders: [CustomHeader] = []
    var createdAt: Date = .init()

    static func primaryKey() -> String? {
        return "id"
    }
}
