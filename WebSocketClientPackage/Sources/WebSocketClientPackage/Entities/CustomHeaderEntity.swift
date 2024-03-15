//
//  CustomHeaderEntity.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/08/03.
//

import Foundation

public struct CustomHeaderEntity: Sendable, Hashable, Identifiable {
    // MARK: - Properties
    public let id: UUID
    private(set) var name: String
    private(set) var value: String

    // MARK: - Initialize
    public init(id: UUID) {
        self.id = id
        self.name = ""
        self.value = ""
    }

    public mutating func setName(_ name: String) {
        self.name = name
    }

    public mutating func setValue(_ value: String) {
        self.value = value
    }
}
