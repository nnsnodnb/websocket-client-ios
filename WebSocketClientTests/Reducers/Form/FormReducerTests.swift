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
                .init(id: .init(0))
            ]
        }

        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(id: .init(0)),
                .init(id: .init(1))
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
                .init(id: .init(0))
            ]
        }
        await store.send(.removeCustomHeader(.init(integer: 0))) {
            $0.customHeaders = []
        }

        // remove empty index
        await store.send(.addCustomHeader) {
            $0.customHeaders = [
                .init(id: .init(1))
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
                .init(id: .init(0))
            ]
        }
        await store.send(.customHeaderNameChanged(0, "Authorization")) {
            var customHeader = CustomHeaderEntity(id: .init(0))
            customHeader.setName("Authorization")
            $0.customHeaders = [
                customHeader
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
                .init(id: .init(0))
            ]
        }
        await store.send(.customHeaderValueChanged(0, "application/json")) {
            var customHeader = CustomHeaderEntity(id: .init(0))
            customHeader.setValue("application/json")
            $0.customHeaders = [
                customHeader
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
            let history = HistoryEntity(
                id: .init(0),
                url: URL(string: "wss://echo.websocket.events")!,
                customHeaders: [],
                messages: [],
                isConnectionSuccess: false,
                createdAt: now
            )
            $0.connection = .init(
                url: URL(string: "wss://echo.websocket.events")!,
                history: history
            )
        }
    }
}
