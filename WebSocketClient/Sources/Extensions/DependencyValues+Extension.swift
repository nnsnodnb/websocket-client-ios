//
//  DependencyValues+Extension.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/18.
//

import ComposableArchitecture
import Foundation

// MARK: - ApplicationClient
extension DependencyValues {
    var application: ApplicationClient {
        get { self[ApplicationClient.self] }
        set { self[ApplicationClient.self] = newValue }
    }
}

// MARK: - BundleClient
extension DependencyValues {
    var bundle: BundleClient {
        get { self[BundleClient.self] }
        set { self[BundleClient.self] = newValue }
    }
}

// MARK: - DatabaseClient
extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

// MARK: - WebSocketClient
extension DependencyValues {
    var webSocketClient: WebSocketClient {
        get { self[WebSocketClient.self] }
        set { self[WebSocketClient.self] = newValue }
    }
}
