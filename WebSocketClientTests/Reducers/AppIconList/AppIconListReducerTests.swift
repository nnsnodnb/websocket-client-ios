//
//  AppIconListReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/04.
//

import ComposableArchitecture
@testable import WebSocketClient
import XCTest

@MainActor
final class AppIconListReducerTests: XCTestCase {
    func testAppIconChanged() async throws {
        let store = TestStore(
            initialState: AppIconListReducer.State(),
            reducer: AppIconListReducer()
        )

        store.dependencies.application = .init(
            canOpenURL: { _ in true },
            open: { _ in true },
            setAlternateIconName: { _ in }
        )

        // default
        await store.send(.appIconChanged(.default))
        await store.receive(.setAlternateIconNameResponse(.success(true)))

        // yellow
        await store.send(.appIconChanged(.yellow))
        await store.receive(.setAlternateIconNameResponse(.success(true)))

        // red
        await store.send(.appIconChanged(.red))
        await store.receive(.setAlternateIconNameResponse(.success(true)))

        // blue
        await store.send(.appIconChanged(.blue))
        await store.receive(.setAlternateIconNameResponse(.success(true)))

        // purple
        await store.send(.appIconChanged(.purple))
        await store.receive(.setAlternateIconNameResponse(.success(true)))

        // black
        await store.send(.appIconChanged(.black))
        await store.receive(.setAlternateIconNameResponse(.success(true)))

        // white
        await store.send(.appIconChanged(.white))
        await store.receive(.setAlternateIconNameResponse(.success(true)))
    }
}
