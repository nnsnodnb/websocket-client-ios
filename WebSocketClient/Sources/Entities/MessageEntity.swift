//
//  MessageEntity.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/08/03.
//

import Foundation

struct MessageEntity: Hashable, Identifiable {
    // MARK: - Properties
    let id: UUID
    let text: String
    let createdAt: Date
}
