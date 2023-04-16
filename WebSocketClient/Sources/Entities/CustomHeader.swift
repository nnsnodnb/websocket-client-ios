//
//  CustomHeader.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import Foundation

struct CustomHeader: Equatable, Sendable {
    // MARK: - Properties
    let name: String
    let value: String
}
