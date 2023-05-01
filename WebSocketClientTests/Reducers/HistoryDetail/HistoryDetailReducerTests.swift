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
                    TextState("本当に削除しますか？")
                },
                actions: {
                    ButtonState(
                        role: .cancel,
                        label: {
                            TextState("キャンセル")
                        }
                    )
                    ButtonState(
                        role: .destructive,
                        action: .send(.confirm),
                        label: {
                            TextState("削除")
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
                TextState("削除に失敗しました")
            }
        }
        await store.send(.alertDismissed) {
            $0.alert = nil
        }
    }
}
