//
//  HistoryDetailReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
import SwiftUINavigation
@testable import WebSocketClient
import XCTest

@MainActor
final class HistoryDetailReducerTests: XCTestCase {
    var history: History!

    override func setUp() {
        super.setUp()
        history = History(
            id: UUID(0).uuidString,
            urlString: "wss://echo.websocket.events",
            messages: [],
            isConnectionSuccess: true,
            customHeaders: [],
            createdAt: .init()
        )
    }

    override func tearDown() {
        super.tearDown()
        history = nil
    }

    func testCheckDelete() async throws {
        let store = TestStore(
            initialState: HistoryDetailReducer.State(history: history),
            reducer: HistoryDetailReducer()
        )

        await store.send(.checkDelete) {
            $0.alert = AlertState(
                title: {
                    TextState(L10n.HistoryDetail.Alert.Confirm.Title.message)
                },
                actions: {
                    ButtonState(
                        role: .cancel,
                        label: {
                            TextState(L10n.HistoryDetail.Alert.Confirm.Title.cancel)
                        }
                    )
                    ButtonState(
                        role: .destructive,
                        action: .send(.confirm),
                        label: {
                            TextState(L10n.HistoryDetail.Alert.Confirm.Title.delete)
                        }
                    )
                }
            )
        }
    }

    func testConfirmSuccess() async throws {
        let store = TestStore(
            initialState: HistoryDetailReducer.State(history: history),
            reducer: HistoryDetailReducer()
        )

        store.dependencies.databaseClient = .init(
            fetchHistories: { _ in [] },
            getHistory: { _ in await self.history },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in }
        )

        await store.send(.confirm)
        await store.receive(.deleteResponse(.success(true)))
        await store.receive(.deleted)
    }

    func testConfirmFailure() async throws {
        let store = TestStore(
            initialState: HistoryDetailReducer.State(history: history),
            reducer: HistoryDetailReducer()
        )

        enum Error: Swift.Error {
            case delete
        }

        store.dependencies.databaseClient = .init(
            fetchHistories: { _ in [] },
            getHistory: { _ in await self.history },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in throw Error.delete}
        )

        await store.send(.confirm)
        await store.receive(.deleteResponse(.failure(Error.delete))) {
            $0.alert = AlertState {
                TextState(L10n.HistoryDetail.Alert.DeletionFailed.Title.message)
            }
        }
        await store.send(.alertDismissed) {
            $0.alert = nil
        }
    }

    func testShowCustomHeaderList() async throws {
        let store = TestStore(
            initialState: HistoryDetailReducer.State(history: history),
            reducer: HistoryDetailReducer()
        )

        await store.send(.showCustomHeaderList) {
            $0.isShowCustomHeaderList = true
        }
    }

    func testDismissCustomHeaderList() async throws {
        let store = TestStore(
            initialState: HistoryDetailReducer.State(history: history),
            reducer: HistoryDetailReducer()
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
