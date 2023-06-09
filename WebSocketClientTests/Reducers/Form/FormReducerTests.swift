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

        store.dependencies.uuid = .incrementing

        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(id: UUID(0).uuidString, name: "", value: "")
            ]
        }

        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(id: UUID(0).uuidString, name: "", value: ""),
                .init(id: UUID(1).uuidString, name: "", value: "")
            ]
        }
    }

    func testRemoveCustomHeader() async {
        let store = TestStore(
            initialState: FormReducer.State(),
            reducer: FormReducer()
        )

        store.dependencies.uuid = .incrementing

        // remove exist index
        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(id: UUID(0).uuidString, name: "", value: "")
            ]
        }
        await store.send(.removeCustomHeader(.init(integer: 0))) {
            $0.customHeaders = []
        }

        // remove empty index
        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(id: UUID(1).uuidString, name: "", value: "")
            ]
        }
        await store.send(.removeCustomHeader(.init(integer: 1)))
    }

    func testCustomHeaderNameChanged() async {
        let store = TestStore(
            initialState: FormReducer.State(),
            reducer: FormReducer()
        )

        store.dependencies.uuid = .incrementing

        // empty index
        await store.send(.customHeaderNameChanged(0, "Authorization"))

        // add & update
        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(id: UUID(0).uuidString, name: "", value: "")
            ]
        }
        await store.send(.customHeaderNameChanged(0, "Authorization")) {
            $0.customHeaders = [
                .init(id: UUID(0).uuidString, name: "Authorization", value: "")
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

        store.dependencies.uuid = .incrementing

        // empty index
        await store.send(.customHeaderValueChanged(0, "application/json"))

        // add & update
        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(id: UUID(0).uuidString, name: "", value: "")
            ]
        }
        await store.send(.customHeaderValueChanged(0, "application/json")) {
            $0.customHeaders = [
                .init(id: UUID(0).uuidString, name: "", value: "application/json")
            ]
        }

        // empty index
        await store.send(.customHeaderNameChanged(1, "no-cache"))
    }

    func testConnect() async {
        let store = TestStore(
            initialState: FormReducer.State(),
            reducer: FormReducer()
        )

        await store.send(.urlChanged("wss://echo.websocket.events")) {
            $0.url = URL(string: "wss://echo.websocket.events")
            $0.customHeaders = []
            $0.isConnectButtonDisable = false
        }

        store.dependencies.uuid = .incrementing
        let now = Date()
        store.dependencies.date = .constant(now)

        await store.send(.connect) {
            let history = History(
                id: UUID(0).uuidString,
                urlString: "wss://echo.websocket.events",
                createdAt: now
            )
            $0.connection = .init(
                url: URL(string: "wss://echo.websocket.events")!,
                history: history
            )
        }
    }
}
