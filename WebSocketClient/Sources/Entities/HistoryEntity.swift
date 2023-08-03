//
//  HistoryEntity.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/08/03.
//

import Foundation

struct HistoryEntity: Hashable, Identifiable {
    // MARK: - Properties
    let id: UUID
    private(set) var url: URL
    private(set) var customHeaders: [CustomHeaderEntity]
    private(set) var messages: [MessageEntity]
    private(set) var isConnectionSuccess: Bool
    let createdAt: Date

    mutating func addToMessages(_ message: MessageEntity) {
        messages.append(message)
    }

    mutating func successfulConnection() {
        isConnectionSuccess = true
    }
}
