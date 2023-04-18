//
//  DependencyValues+Extension.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/18.
//

import ComposableArchitecture
import Foundation

extension DependencyValues {
    var webSocketClient: WebSocketClient {
        get { self[WebSocketClient.self] }
        set { self[WebSocketClient.self] = newValue }
    }
}
