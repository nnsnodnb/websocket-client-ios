//
//  HistoryEntity.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/08/03.
//

import Foundation

public struct HistoryEntity: Sendable, Hashable, Identifiable {
    // MARK: - Properties
    public let id: UUID
    private(set) var url: URL
    private(set) var customHeaders: [CustomHeaderEntity]
    private(set) var messages: [MessageEntity]
    private(set) var isConnectionSuccess: Bool
    public let createdAt: Date

    public mutating func addToMessages(_ message: MessageEntity) {
        messages.append(message)
    }

    public mutating func successfulConnection() {
        isConnectionSuccess = true
    }
}
