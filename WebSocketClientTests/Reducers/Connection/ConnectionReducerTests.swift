//
//  ConnectionReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
@testable import WebSocketClient
import XCTest

@MainActor
final class ConnectionReducerTests: XCTestCase {
    private var history: HistoryEntity!

    override func setUp() {
        super.setUp()
        history = .init(
            id: .init(0),
            url: URL(string: "wss://echo.websocket.events")!,
            customHeaders: [],
            messages: [],
            isConnectionSuccess: false,
            createdAt: .init()
        )
    }

    override func tearDown() {
        super.tearDown()
        history = nil
    }

    func testShowCustomHeaderList() async throws {
        let store = TestStore(
            initialState: ConnectionReducer.State(
                url: URL(string: "wss://echo.websocket.events")!,
                history: history),
            reducer: ConnectionReducer()
        )

        // show
        await store.send(.showCustomHeaderList) {
            $0.isShowCustomHeaderList = true
        }
    }

    func testDismissCustomHeaderList() async throws {
        let store = TestStore(
            initialState: ConnectionReducer.State(
                url: URL(string: "wss://echo.websocket.events")!,
                history: history),
            reducer: ConnectionReducer()
        )

        // already dismiss
        await store.send(.dismissCustomHeaderList)

        // dismiss
        await store.send(.showCustomHeaderList) {
            $0.isShowCustomHeaderList = true
        }
        await store.send(.dismissCustomHeaderList) {
            $0.isShowCustomHeaderList = false
        }
    }
}
