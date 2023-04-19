//
//  DatabaseClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/19.
//

import ComposableArchitecture
import Foundation

struct DatabaseClient {
}

// MARK: - DependencyKey
extension DatabaseClient: DependencyKey {
    static var liveValue = Self()

    static var testValue = Self()
}
