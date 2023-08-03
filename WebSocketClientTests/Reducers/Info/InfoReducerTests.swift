//
//  InfoReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/04/28.
//

import ComposableArchitecture
@testable import WebSocketClient
import XCTest

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

    func testCheckDeleteAllData() async {
        let store = TestStore(
            initialState: InfoReducer.State(),
            reducer: InfoReducer()
        )

        await store.send(.checkDeleteAllData) {
            $0.alert = AlertState(
                title: {
                    TextState(L10n.Info.Alert.Confirm.Title.message)
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
                        action: .send(.deleteAllData),
                        label: {
                            TextState(L10n.Alert.Button.Title.delete)
                        }
                    )
                }
            )
        }
        await store.send(.alertDismissed) {
            $0.alert = nil
        }
    }

    func testDeleteAllDataSuccess() async {
        let store = TestStore(
            initialState: InfoReducer.State(),
            reducer: InfoReducer()
        )

        store.dependencies.databaseClient = .init(
            fetchHistories: { _ in [] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: {}
        )

        await store.send(.deleteAllData)
        await store.receive(.deleteAllDataResponse(.success(true)))
    }

    func testDeleteAllDataFailure() async {
        let store = TestStore(
            initialState: InfoReducer.State(),
            reducer: InfoReducer()
        )

        enum Error: Swift.Error {
            case delete
        }

        store.dependencies.databaseClient = .init(
            fetchHistories: { _ in [] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: { throw Error.delete }
        )

        await store.send(.deleteAllData)
        await store.receive(.deleteAllDataResponse(.failure(Error.delete))) {
            $0.alert = AlertState {
                TextState(L10n.Info.Alert.DeletionFailed.Title.message)
            }
        }
        await store.send(.alertDismissed) {
            $0.alert = nil
        }
    }
}
