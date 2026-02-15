//
//  HistoryModel.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/14.
//

import Foundation
import SwiftData

@Model
public class HistoryModel: Hashable {
  // MARK: - Properties
  @Attribute(.unique)
  public var id: UUID
  public var urlString: String
  public var isConnectionSuccess: Bool
  public var createdAt: Date

  @Relationship(deleteRule: .cascade, inverse: \CustomHeaderModel.history)
  public var customHeaders: [CustomHeaderModel]
  @Relationship(deleteRule: .cascade, inverse: \MessageModel.history)
  public var messages: [MessageModel]

  // MARK: - Initialize
  public init(
    id: UUID,
    urlString: String,
    isConnectionSuccess: Bool = false,
    createdAt: Date = .init(),
    customHeaders: [CustomHeaderModel] = [],
    messages: [MessageModel] = [],
  ) {
    self.id = id
    self.urlString = urlString
    self.isConnectionSuccess = isConnectionSuccess
    self.createdAt = createdAt
    self.customHeaders = customHeaders
    self.messages = messages
  }
}
