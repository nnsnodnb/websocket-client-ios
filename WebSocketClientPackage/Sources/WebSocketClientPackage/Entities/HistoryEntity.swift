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
  public private(set) var url: URL
  public private(set) var customHeaders: [CustomHeaderEntity]
  public private(set) var messages: [MessageEntity]
  public private(set) var isConnectionSuccess: Bool
  public let createdAt: Date

  // MARK: - Initialize
  public init(
    id: UUID,
    url: URL,
    customHeaders: [CustomHeaderEntity],
    messages: [MessageEntity],
    isConnectionSuccess: Bool,
    createdAt: Date,
  ) {
    self.id = id
    self.url = url
    self.customHeaders = customHeaders
    self.messages = messages
    self.isConnectionSuccess = isConnectionSuccess
    self.createdAt = createdAt
  }

  public mutating func addToMessages(_ message: MessageEntity) {
    messages.append(message)
  }

  public mutating func successfulConnection() {
    isConnectionSuccess = true
  }
}
