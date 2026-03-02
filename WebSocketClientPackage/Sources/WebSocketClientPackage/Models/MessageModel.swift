//
//  MessageModel.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/14.
//

import Foundation
import SwiftData

@Model
public class MessageModel: Hashable {
  // MARK: - Properties
  @Attribute(.unique)
  public var id: UUID
  public var text: String
  public var createdAt: Date

  @Relationship public var history: HistoryModel

  // MARK: - Initialize
  public init(
    id: UUID,
    text: String,
    createdAt: Date = .init(),
    history: HistoryModel,
  ) {
    self.id = id
    self.text = text
    self.createdAt = createdAt
    self.history = history
  }
}
