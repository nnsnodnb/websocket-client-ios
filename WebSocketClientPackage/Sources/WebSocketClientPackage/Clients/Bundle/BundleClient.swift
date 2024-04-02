//
//  BundleClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/24.
//

import ComposableArchitecture
import Foundation

@DependencyClient
public struct BundleClient: Sendable {
    var shortVersionString: @Sendable () -> String = { "" }
}

// MARK: - DependencyKey
extension BundleClient: DependencyKey {
    public static let liveValue: Self = .init(
        shortVersionString: {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        }
    )

    public static let testValue = Self()
}
