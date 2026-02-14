//
//  CustomHeaderModel.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/02/14.
//

import Foundation
import SwiftData

@Model
package class CustomHeaderModel: Hashable {
  // MARK: - Properties
  @Attribute(.unique)
  package var id: UUID
  package var name: String
  package var value: String

  @Relationship(deleteRule: .cascade, inverse: \HistoryModel.id)
  package var history: HistoryModel?

  // MARK: - Initialize
  package init(id: UUID, name: String, value: String) {
    self.id = id
    self.name = name
    self.value = value
  }
}
