//
//  InfoReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/04/28.
//

import ComposableArchitecture
import XCTest
@testable import WebSocketClient

@MainActor
final class InfoReducerTests: XCTestCase {
    func testStart() async {
        let store = TestStore(
            initialState: InfoReducer.State(),
            reducer: InfoReducer()
        )

        store.dependencies.bundle.shortVersionString = { "1.0.0" }

        await store.send(.start) {
            $0.version = "1.0.0"
        }
    }
}
