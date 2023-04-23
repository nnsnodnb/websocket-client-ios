//
//  ApplicationClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/23.
//

import ComposableArchitecture
import UIKit
import XCTestDynamicOverlay

struct ApplicationClient {
    var canOpenURL: (URL) -> Bool
    var open: @Sendable (URL) async -> Bool
}

// MARK: - DependencyKey
extension ApplicationClient: DependencyKey {
    public static var liveValue: Self {
        return Self(
            canOpenURL: { UIApplication.shared.canOpenURL($0) },
            open: { @MainActor in await UIApplication.shared.open($0) }
        )
    }

    public static var testValue = Self(
        canOpenURL: unimplemented("\(Self.self).canOpenURL"),
        open: unimplemented("\(Self.self).open")
    )
}
