//
//  MessageEntity.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/08/03.
//

import Foundation

public struct MessageEntity: Sendable, Hashable, Identifiable {
    // MARK: - Properties
    public let id: UUID
    public let text: String
    public let createdAt: Date
}
