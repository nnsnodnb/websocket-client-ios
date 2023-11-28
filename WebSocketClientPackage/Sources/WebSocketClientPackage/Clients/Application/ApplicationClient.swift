//
//  ApplicationClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/23.
//

import ComposableArchitecture
import UIKit

@DependencyClient
public struct ApplicationClient {
    public var canOpenURL: (URL) -> Bool = { _ in false }
    public var open: @Sendable (URL) async -> Bool = { _ in false }
    public var setAlternateIconName: @Sendable (String?) async throws -> Void
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

    public static var testValue: Self = .init()
}
