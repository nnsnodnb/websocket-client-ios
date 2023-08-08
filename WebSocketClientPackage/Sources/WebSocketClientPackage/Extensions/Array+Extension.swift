//
//  Array+Extension.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import Foundation

public extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
