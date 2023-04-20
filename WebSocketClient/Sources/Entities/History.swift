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
    var id = UUID().uuidString
    var urlString: String = ""

    static func primaryKey() -> String? {
        return "id"
    }
}
