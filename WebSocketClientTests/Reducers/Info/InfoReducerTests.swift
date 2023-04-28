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

    func testURLSelected() async {
        let store = TestStore(
            initialState: InfoReducer.State(),
            reducer: InfoReducer()
        )

        await store.send(.urlSelected(URL(string: "https://github.com/nnsnodnb/websocket-client-ios")!)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/websocket-client-ios")
        }
    }

    func testSafariOpen() async {
        let store = TestStore(
            initialState: InfoReducer.State(),
            reducer: InfoReducer()
        )

        // no exist url
        await store.send(.safariOpen)

        // exist url
        await store.send(.urlSelected(URL(string: "https://github.com/nnsnodnb/websocket-client-ios")!)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/websocket-client-ios")
        }
        await store.send(.safariOpen) {
            $0.isShowSafari = true
        }
    }

    func testSafariDismiss() async {
        let store = TestStore(
            initialState: InfoReducer.State(),
            reducer: InfoReducer()
        )

        await store.send(.urlSelected(URL(string: "https://github.com/nnsnodnb/websocket-client-ios")!)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/websocket-client-ios")
        }
        await store.send(.safariOpen) {
            $0.isShowSafari = true
        }
        await store.send(.safariDismiss) {
            $0.url = nil
            $0.isShowSafari = false
        }
    }

    func testBrowserOpen() async {
        let store = TestStore(
            initialState: InfoReducer.State(),
            reducer: InfoReducer()
        )

        store.dependencies.application.canOpenURL = { _ in true }
        store.dependencies.application.open = { _ in true }

        await store.send(.browserOpen(URL(string: "https://example.com")!))
        await store.receive(.browserOpenResponse(.success(true)))
    }
}
