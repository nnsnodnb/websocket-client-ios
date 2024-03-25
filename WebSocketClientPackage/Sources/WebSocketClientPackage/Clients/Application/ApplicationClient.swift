//
//  ApplicationClient.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/23.
//

import ComposableArchitecture
import UIKit

@DependencyClient
public struct ApplicationClient: Sendable {
    public var canOpenURL: @Sendable (URL) async -> Bool = { _ in false }
    public var open: @Sendable (URL) async throws -> Bool
    public var setAlternateIconName: @Sendable (String?) async throws -> Void
}

// MARK: - DependencyKey
extension ApplicationClient: DependencyKey {
    public static let liveValue: Self = .init(
        canOpenURL: { @MainActor in UIApplication.shared.canOpenURL($0) },
        open: { @MainActor in await UIApplication.shared.open($0) },
        setAlternateIconName: { @MainActor in try await UIApplication.shared.setAlternateIconName($0) }
    )

    public static let testValue: Self = .init()
}
