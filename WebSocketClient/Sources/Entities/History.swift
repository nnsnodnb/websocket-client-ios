//
//  History.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/19.
//

import Foundation
import Unrealm

struct History: Realmable, Identifiable, Equatable {
    // MARK: - Properties
    let id = UUID().uuidString
    var urlString: String = ""
    var messages: [Message] = []
    var isConnectionSuccess = false
    let createdAt: Date = .init()

    static func primaryKey() -> String? {
        return "id"
    }
}
