//
//  BundleClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/24.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct BundleClient {
    var shortVersionString: () -> String
}

// MARK: - DependencyKey
extension BundleClient: DependencyKey {
    static var liveValue: Self {
        return Self(
            shortVersionString: {
                Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
            }
        )
    }

    static var testValue = Self(
        shortVersionString: unimplemented("\(Self.self).shortVersionString")
    )
}
