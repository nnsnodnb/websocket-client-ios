//
//  HistoryModel.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/14.
//

import Foundation
import SwiftData

@Model
package class HistoryModel: Hashable {
  // MARK: - Properties
  @Attribute(.unique)
  package var id: UUID
  package var urlString: String
  package var isConnectionSuccess: Bool
  package var createdAt: Date

  @Relationship(deleteRule: .cascade, inverse: \CustomHeaderModel.id)
  package var customHeaders: [CustomHeaderModel] = []
  @Relationship(deleteRule: .cascade, inverse: \MessageModel.id)
  package var messages: [MessageModel] = []

  // MARK: - Initialize
  package init(
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
