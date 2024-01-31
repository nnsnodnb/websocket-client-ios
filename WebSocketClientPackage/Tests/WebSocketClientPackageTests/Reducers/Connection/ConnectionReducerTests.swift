//
//  ConnectionReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
@testable import WebSocketClientPackage
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
                history: history
            )
        ) {
            ConnectionReducer()
        }

        // show
        await store.send(.showedCustomHeaderList(true)) {
            $0.isShowCustomHeaderList = true
        }
    }

    func testDismissCustomHeaderList() async throws {
        let store = TestStore(
            initialState: ConnectionReducer.State(
                url: URL(string: "wss://echo.websocket.events")!,
                history: history
            )
        ) {
            ConnectionReducer()
        }

        // already dismiss
        await store.send(.showedCustomHeaderList(false))

        // dismiss
        await store.send(.showedCustomHeaderList(true)) {
            $0.isShowCustomHeaderList = true
        }
        await store.send(.showedCustomHeaderList(false)) {
            $0.isShowCustomHeaderList = false
        }
    }
}
