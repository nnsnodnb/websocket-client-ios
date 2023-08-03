//
//  IdentifiedArrayOf+Extension.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/02.
//

import IdentifiedCollections

extension IdentifiedArrayOf where Element: Identifiable {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
