//
//  FormReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/04/16.
//

import ComposableArchitecture
@testable import WebSocketClient
import XCTest

@MainActor
final class FormReducerTests: XCTestCase {
    func testURLChanged() async {
        let store = TestStore(
            initialState: FormReducer.State(),
            reducer: FormReducer()
        )

        await store.send(.urlChanged("wss://echo.websocket.events")) {
            $0.url = URL(string: "wss://echo.websocket.events")
            $0.customHeaders = []
            $0.isConnectButtonDisable = false
        }
    }

    func testAddCustomHeader() async {
        let store = TestStore(
            initialState: FormReducer.State(),
            reducer: FormReducer()
        )

        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(name: "", value: "")
            ]
        }

        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(name: "", value: ""),
                .init(name: "", value: "")
            ]
        }
    }

    func testRemoveCustomHeader() async {
        let store = TestStore(
            initialState: FormReducer.State(),
            reducer: FormReducer()
        )

        // remove exist index
        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(name: "", value: "")
            ]
        }
        await store.send(.removeCustomHeader(.init(integer: 0))) {
            $0.customHeaders = []
        }

        // remove empty index
        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(name: "", value: "")
            ]
        }
        await store.send(.removeCustomHeader(.init(integer: 1)))
    }

    func testCustomHeaderNameChanged() async {
        let store = TestStore(
            initialState: FormReducer.State(),
            reducer: FormReducer()
        )

        // empty index
        await store.send(.customHeaderNameChanged(0, "Authorization"))

        // add & update
        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(name: "", value: "")
            ]
        }
        await store.send(.customHeaderNameChanged(0, "Authorization")) {
            $0.customHeaders = [
                .init(name: "Authorization", value: "")
            ]
        }

        // empty index
        await store.send(.customHeaderNameChanged(1, "Content-Type"))
    }

    func testCustomHeaderValueChanged() async {
        let store = TestStore(
            initialState: FormReducer.State(),
            reducer: FormReducer()
        )

        // empty index
        await store.send(.customHeaderValueChanged(0, "application/json"))

        // add & update
        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(name: "", value: "")
            ]
        }
        await store.send(.customHeaderValueChanged(0, "application/json")) {
            $0.customHeaders = [
                .init(name: "", value: "application/json")
            ]
        }

        // empty index
        await store.send(.customHeaderNameChanged(1, "no-cache"))
    }
}
