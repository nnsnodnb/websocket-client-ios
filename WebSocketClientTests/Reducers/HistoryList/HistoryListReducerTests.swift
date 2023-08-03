//
//  HistoryListReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
@testable import WebSocketClient
import XCTest

@MainActor
final class HistoryListReducerTests: XCTestCase {
    // MARK: - Properties
    private var managedObjectContext: NSManagedObjectContextProtocol!

    // MARK: - Life Cycle
    override func setUp() {
        super.setUp()
        self.managedObjectContext = DatabaseClient.testValue.managedObjectContext()
    }

    override func tearDown() {
        super.tearDown()
        self.managedObjectContext = nil
    }

    func testSetNavigation() async throws {
        let store = TestStore(
            initialState: HistoryListReducer.State(),
            reducer: HistoryListReducer()
        )

        let history = CDHistory.insertNewObject(managedObjectContext: managedObjectContext)
        history.id = .init(0)
        history.urlString = "wss://echo.websocket.events"
        history.messages = .init(array: [])
        history.isConnectionSuccess = true
        history.customHeaders = .init(array: [])
        history.createdAt = .init()

        store.dependencies.databaseClient = .init(
            managedObjectContext: DatabaseClient.testValue.managedObjectContext,
            fetchHistories: { _ in [history] },
            getHistory: { _ in nil },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: {}
        )

        await store.send(.fetch)
        await store.receive(.fetchResponse(.success([history]))) {
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
        let store = TestStore(
            initialState: HistoryListReducer.State(),
            reducer: HistoryListReducer()
        )

        let history = CDHistory.insertNewObject(managedObjectContext: managedObjectContext)
        history.id = .init(0)
        history.urlString = "wss://echo.websocket.events"
        history.messages = .init(array: [])
        history.isConnectionSuccess = true
        history.customHeaders = .init(array: [])
        history.createdAt = .init()

        store.dependencies.databaseClient = .init(
            managedObjectContext: DatabaseClient.testValue.managedObjectContext,
            fetchHistories: { _ in [history] },
            getHistory: { _ in nil },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: {}
        )

        await store.send(.fetch)
        await store.receive(.fetchResponse(.success([history]))) {
            $0.histories = .init(uniqueElements: [history])
        }

        // delete success
        await store.send(.deleteHistory(.init(integer: 0)))
        await store.receive(.deleteHistoryResponse(.success(history))) {
            $0.histories = .init(uniqueElements: [])
        }
    }

    func testDeleteHistoryFailure() async throws {
        enum Error: Swift.Error {
            case delete
        }

        let store = TestStore(
            initialState: HistoryListReducer.State(),
            reducer: HistoryListReducer()
        )

        let history = CDHistory.insertNewObject(managedObjectContext: managedObjectContext)
        history.id = .init(0)
        history.urlString = "wss://echo.websocket.events"
        history.messages = .init(array: [])
        history.isConnectionSuccess = true
        history.customHeaders = .init(array: [])
        history.createdAt = .init()

        store.dependencies.databaseClient = .init(
            managedObjectContext: DatabaseClient.testValue.managedObjectContext,
            fetchHistories: { _ in [history] },
            getHistory: { _ in nil },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in throw Error.delete },
            deleteAllData: {}
        )

        await store.send(.fetch)
        await store.receive(.fetchResponse(.success([history]))) {
            $0.histories = .init(uniqueElements: [history])
        }

        // delete failure
        await store.send(.deleteHistory(.init(integer: 0)))
        await store.receive(.deleteHistoryResponse(.failure(Error.delete)))
    }

    func testHistoryDetailDeleted() async throws {
        let store = TestStore(
            initialState: HistoryListReducer.State(),
            reducer: HistoryListReducer()
        )

        let history = CDHistory.insertNewObject(managedObjectContext: managedObjectContext)
        history.id = .init(0)
        history.urlString = "wss://echo.websocket.events"
        history.messages = .init(array: [])
        history.isConnectionSuccess = true
        history.customHeaders = .init(array: [])
        history.createdAt = .init()

        store.dependencies.databaseClient = .init(
            managedObjectContext: DatabaseClient.testValue.managedObjectContext,
            fetchHistories: { _ in [history] },
            getHistory: { _ in nil },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: {}
        )

        await store.send(.fetch)
        await store.receive(.fetchResponse(.success([history]))) {
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
        await store.receive(.setNavigation(nil)) {
            $0.paths = []
            $0.selectionHistory = nil
        }
    }
}
