//
//  CustomHeaderModel.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/14.
//

import Foundation
import SwiftData

@Model
public class CustomHeaderModel: Hashable {
  // MARK: - Properties
  @Attribute(.unique)
  public var id: UUID
  public var name: String
  public var value: String

  @Relationship public var history: HistoryModel

  // MARK: - Initialize
  public init(id: UUID, name: String, value: String, history: HistoryModel) {
    self.id = id
    self.name = name
    self.value = value
    self.history = history
  }
}
