//
//  URLSessionWebSocketTask+Extension.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/17.
//

import Foundation

extension URLSessionWebSocketTask {
    func sendPing() async throws {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.sendPing { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
