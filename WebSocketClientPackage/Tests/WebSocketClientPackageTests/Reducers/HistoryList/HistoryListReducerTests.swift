//
//  HistoryListReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
@testable import WebSocketClientPackage
import XCTest

@MainActor
final class HistoryListReducerTests: XCTestCase {
    func testSetNavigation() async throws {
        let history = HistoryEntity(
            id: .init(0),
            url: URL(string: "wss://echo.websocket.events")!,
            customHeaders: [],
            messages: [],
            isConnectionSuccess: true,
            createdAt: .init()
        )
        let databaseClient = DatabaseClient(
            fetchHistories: { _ in [history] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: {}
        )
        let store = TestStore(
            initialState: HistoryListReducer.State()
        ) {
            HistoryListReducer()
                .dependency(databaseClient)
        }

        await store.send(.fetch)
        await store.receive(\.fetchResponse, [history]) {
            $0.histories = .init(uniqueElements: [history])
        }

        // some
        await store.send(.setNavigation(history)) {
            $0.paths = [.historyDetail]
            $0.selectionHistory = .init(.init(history: history), id: history)
        }

        // none
        await store.send(.setNavigation(nil)) {
            $0.paths = []
            $0.selectionHistory = nil
        }
    }

    func testDeleteHistorySuccess() async throws {
        let history = HistoryEntity(
            id: .init(0),
            url: URL(string: "wss://echo.websocket.events")!,
            customHeaders: [],
            messages: [],
            isConnectionSuccess: true,
            createdAt: .init()
        )
        let databaseClient = DatabaseClient(
            fetchHistories: { _ in [history] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: {}
        )
        let store = TestStore(
            initialState: HistoryListReducer.State()
        ) {
            HistoryListReducer()
                .dependency(databaseClient)
        }

        await store.send(.fetch)
        await store.receive(\.fetchResponse, [history]) {
            $0.histories = .init(uniqueElements: [history])
        }

        // delete success
        await store.send(.deleteHistory(.init(integer: 0)))
        await store.receive(\.deleteHistoryResponse, history) {
            $0.histories = .init(uniqueElements: [])
        }
    }

    func testDeleteHistoryFailure() async throws {
        enum Error: Swift.Error {
            case delete
        }

        let history = HistoryEntity(
            id: .init(0),
            url: URL(string: "wss://echo.websocket.events")!,
            customHeaders: [],
            messages: [],
            isConnectionSuccess: true,
            createdAt: .init()
        )
        let databaseClient = DatabaseClient(
            fetchHistories: { _ in [history] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in throw Error.delete },
            deleteAllData: {}
        )
        let store = TestStore(
            initialState: HistoryListReducer.State()
        ) {
            HistoryListReducer()
                .dependency(databaseClient)
        }

        await store.send(.fetch)
        await store.receive(\.fetchResponse, [history]) {
            $0.histories = .init(uniqueElements: [history])
        }

        // delete failure
        await store.send(.deleteHistory(.init(integer: 0)))
        await store.receive(\.error.deleteHistory)
    }

    func testHistoryDetailDeleted() async throws {
        let history = HistoryEntity(
            id: .init(0),
            url: URL(string: "wss://echo.websocket.events")!,
            customHeaders: [],
            messages: [],
            isConnectionSuccess: true,
            createdAt: .init()
        )
        let databaseClient = DatabaseClient(
            fetchHistories: { _ in [history] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: {}
        )
        let store = TestStore(
            initialState: HistoryListReducer.State()
        ) {
            HistoryListReducer()
                .dependency(databaseClient)
        }

        await store.send(.fetch)
        await store.receive(\.fetchResponse, [history]) {
            $0.histories = .init(uniqueElements: [history])
        }

        await store.send(.setNavigation(history)) {
            $0.paths = [.historyDetail]
            $0.selectionHistory = .init(.init(history: history), id: history)
        }

        // deleted
        await store.send(.historyDetail(.deleted)) {
            $0.histories = .init(uniqueElements: [])
        }
        await store.receive(\.setNavigation, nil) {
            $0.paths = []
            $0.selectionHistory = nil
        }
    }
}
