//
//  HistoryDetailReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
@testable import WebSocketClientPackage
import XCTest

@MainActor
final class HistoryDetailReducerTests: XCTestCase {
    private var history: HistoryEntity!

    override func setUp() {
        super.setUp()
        history = .init(
            id: .init(0),
            url: URL(string: "wss://echo.websocket.events")!,
            customHeaders: [],
            messages: [],
            isConnectionSuccess: true,
            createdAt: .init()
        )
    }

    override func tearDown() {
        super.tearDown()
        history = nil
    }

    func testCheckDelete() async throws {
        let store = TestStore(
            initialState: HistoryDetailReducer.State(history: history)
        ) {
            HistoryDetailReducer()
        }

        await store.send(.checkDelete) {
            $0.alert = AlertState(
                title: {
                    TextState(L10n.HistoryDetail.Alert.Confirm.Title.message)
                },
                actions: {
                    ButtonState(
                        role: .cancel,
                        label: {
                            TextState(L10n.Alert.Button.Title.cancel)
                        }
                    )
                    ButtonState(
                        role: .destructive,
                        action: .send(.confirm),
                        label: {
                            TextState(L10n.Alert.Button.Title.delete)
                        }
                    )
                }
            )
        }
    }

    func testConfirmSuccess() async throws {
        let store = TestStore(
            initialState: HistoryDetailReducer.State(history: history)
        ) {
            HistoryDetailReducer()
        }

        store.dependencies.databaseClient = .init(
            fetchHistories: { _ in [] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: {}
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
                            TextState(L10n.Alert.Button.Title.cancel)
                        }
                    )
                    ButtonState(
                        role: .destructive,
                        action: .send(.confirm),
                        label: {
                            TextState(L10n.Alert.Button.Title.delete)
                        }
                    )
                }
            )
        }
        await store.send(.alert(.presented(.confirm))) {
            $0.alert = nil
        }
        await store.receive(\.deleteResponse.success)
        await store.receive(\.deleted)
    }

    func testConfirmFailure() async throws {
        let store = TestStore(
            initialState: HistoryDetailReducer.State(history: history)
        ) {
            HistoryDetailReducer()
        }

        enum Error: Swift.Error {
            case delete
        }

        store.dependencies.databaseClient = .init(
            fetchHistories: { _ in [] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in throw Error.delete },
            deleteAllData: {}
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
                            TextState(L10n.Alert.Button.Title.cancel)
                        }
                    )
                    ButtonState(
                        role: .destructive,
                        action: .send(.confirm),
                        label: {
                            TextState(L10n.Alert.Button.Title.delete)
                        }
                    )
                }
            )
        }
        await store.send(.alert(.presented(.confirm))) {
            $0.alert = nil
        }
        await store.receive(\.deleteResponse.failure) {
            $0.alert = AlertState {
                TextState(L10n.HistoryDetail.Alert.DeletionFailed.Title.message)
            }
        }
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
    }

    func testShowCustomHeaderList() async throws {
        let store = TestStore(
            initialState: HistoryDetailReducer.State(history: history)
        ) {
            HistoryDetailReducer()
        }

        await store.send(.showCustomHeaderList) {
            $0.isShowCustomHeaderList = true
        }
    }

    func testDismissCustomHeaderList() async throws {
        let store = TestStore(
            initialState: HistoryDetailReducer.State(history: history)
        ) {
            HistoryDetailReducer()
        }

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
