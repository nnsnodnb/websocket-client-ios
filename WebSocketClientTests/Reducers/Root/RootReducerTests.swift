//
//  RootReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/04/24.
//

import ComposableArchitecture
import XCTest
@testable import WebSocketClient

@MainActor
final class RootReducerTests: XCTestCase {
    func testOnAppear() async {
        let store = TestStore(
            initialState: RootReducer.State(),
            reducer: RootReducer()
        )

        store.dependencies.bundle.shortVersionString = { "v1.0.0" }

        await store.send(.onAppear) {
            $0.version = "v1.0.0"
        }
    }
}
