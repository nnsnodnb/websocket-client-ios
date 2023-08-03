//
//  CustomHeaderEntity.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/08/03.
//

import Foundation

struct CustomHeaderEntity: Hashable, Identifiable {
    // MARK: - Properties
    let id: UUID
    private(set) var name: String
    private(set) var value: String

    // MARK: - Initialize
    init(id: UUID) {
        self.id = id
        self.name = ""
        self.value = ""
    }

    mutating func setName(_ name: String) {
        self.name = name
    }

    mutating func setValue(_ value: String) {
        self.value = value
    }
}
