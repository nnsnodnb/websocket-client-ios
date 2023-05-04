//
//  CustomHeader.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import Foundation
import Unrealm

struct CustomHeader: Realmable, Hashable, Sendable {
    // MARK: - Properties
    var id: String = ""
    var name: String = ""
    var value: String = ""

    static func primaryKey() -> String? {
        return "id"
    }
}
