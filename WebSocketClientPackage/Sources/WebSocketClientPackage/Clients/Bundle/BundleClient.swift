//
//  BundleClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/24.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

public struct BundleClient {
    var shortVersionString: () -> String
}

// MARK: - DependencyKey
extension BundleClient: DependencyKey {
    public static var liveValue: Self {
        return Self(
            shortVersionString: {
                Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
            }
        )
    }

    public static var testValue = Self(
        shortVersionString: unimplemented("\(Self.self).shortVersionString")
    )
}
