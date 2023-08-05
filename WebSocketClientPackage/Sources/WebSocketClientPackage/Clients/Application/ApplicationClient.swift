//
//  ApplicationClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/23.
//

import ComposableArchitecture
import UIKit
import XCTestDynamicOverlay

public struct ApplicationClient {
    public var canOpenURL: (URL) -> Bool
    public var open: @Sendable (URL) async -> Bool
    public var setAlternateIconName: @Sendable (String?) async throws -> Void

    // MARK: - Initialize
    public init(
        canOpenURL: @escaping (URL) -> Bool,
        open: @escaping @Sendable (URL) async -> Bool,
        setAlternateIconName: @escaping @Sendable (String?) async throws -> Void
    ) {
        self.canOpenURL = canOpenURL
        self.open = open
        self.setAlternateIconName = setAlternateIconName
    }
}

// MARK: - DependencyKey
extension ApplicationClient: DependencyKey {
    public static var liveValue: Self {
        return Self(
            canOpenURL: { UIApplication.shared.canOpenURL($0) },
            open: { @MainActor in await UIApplication.shared.open($0) },
            setAlternateIconName: { @MainActor in try await UIApplication.shared.setAlternateIconName($0) }
        )
    }

    public static var testValue: Self {
        return Self(
            canOpenURL: unimplemented("\(Self.self).canOpenURL"),
            open: unimplemented("\(Self.self).open"),
            setAlternateIconName: unimplemented("\(Self.self).setAlternateIconName")
        )
    }
}
