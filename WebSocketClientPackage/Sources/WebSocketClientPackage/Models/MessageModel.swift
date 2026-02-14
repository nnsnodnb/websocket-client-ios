//
//  MessageModel.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/14.
//

import Foundation
import SwiftData

@Model
package class MessageModel: Hashable {
  // MARK: - Properties
  @Attribute(.unique)
  package var id: UUID
  package var text: String
  package var createdAt: Date

  @Relationship(deleteRule: .cascade, inverse: \HistoryModel.id)
  package var history: HistoryModel?

  // MARK: - Initialize
  package init(
    id: UUID,
    text: String,
    createdAt: Date = .init(),
    history: HistoryModel? = nil,
  ) {
    self.id = id
    self.text = text
    self.createdAt = createdAt
    self.history = history
  }
}
