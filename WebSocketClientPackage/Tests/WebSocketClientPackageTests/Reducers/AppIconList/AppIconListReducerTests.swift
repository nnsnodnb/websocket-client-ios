//
//  AppIconListReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/04.
//

import ComposableArchitecture
@testable import WebSocketClientPackage
import XCTest

final class AppIconListReducerTests: XCTestCase {
    @MainActor
    func testAppIconChanged() async throws {
        let application = ApplicationClient(
            canOpenURL: { _ in true },
            open: { _ in true },
            setAlternateIconName: { _ in }
        )
        let store = TestStore(
            initialState: AppIconListReducer.State()
        ) {
            AppIconListReducer()
                .dependency(application)
        }

        // default
        await store.send(.appIconChanged(.default))
        await store.receive(\.setAlternateIconNameResponse)

        // yellow
        await store.send(.appIconChanged(.yellow))
        await store.receive(\.setAlternateIconNameResponse)

        // red
        await store.send(.appIconChanged(.red))
        await store.receive(\.setAlternateIconNameResponse)

        // blue
        await store.send(.appIconChanged(.blue))
        await store.receive(\.setAlternateIconNameResponse)

        // purple
        await store.send(.appIconChanged(.purple))
        await store.receive(\.setAlternateIconNameResponse)

        // black
        await store.send(.appIconChanged(.black))
        await store.receive(\.setAlternateIconNameResponse)

        // white
        await store.send(.appIconChanged(.white))
        await store.receive(\.setAlternateIconNameResponse)
    }
}
