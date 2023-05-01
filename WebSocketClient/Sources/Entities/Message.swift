//
//  Message.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

import Foundation
import Unrealm

struct Message: Realmable, Hashable {
    // MARK: - Properties
    let id = UUID().uuidString
    var text: String = ""
    let createdAt: Date = .init()

    static func primaryKey() -> String? {
        return "id"
    }
}
