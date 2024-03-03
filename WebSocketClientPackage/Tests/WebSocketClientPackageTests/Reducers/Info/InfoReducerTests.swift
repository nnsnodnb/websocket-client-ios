//
//  InfoReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/04/28.
//

import ComposableArchitecture
@testable import WebSocketClientPackage
import XCTest

@MainActor
final class InfoReducerTests: XCTestCase {
    func testStart() async {
        let bundle = BundleClient(
            shortVersionString: { "1.0.0" }
        )
        let store = TestStore(
            initialState: InfoReducer.State()
        ) {
            InfoReducer()
                .dependency(bundle)
        }

        await store.send(.start) {
            $0.version = "1.0.0"
        }
    }

    func testURLSelected() async {
        let store = TestStore(
            initialState: InfoReducer.State()
        ) {
            InfoReducer()
        }

        await store.send(.urlSelected(URL(string: "https://github.com/nnsnodnb/websocket-client-ios")!)) {
            $0.url = URL(string: "https://github.com/nnsnodnb/websocket-client-ios")
        }
        await store.send(.urlSelected(nil)) {
            $0.url = nil
        }
    }

    func testBrowserOpen() async {
        let application = ApplicationClient(
            canOpenURL: { _ in true },
            open: { _ in true },
            setAlternateIconName: { _ in }
        )
        let store = TestStore(
            initialState: InfoReducer.State()
        ) {
            InfoReducer()
                .dependency(application)
        }

        await store.send(.browserOpen(URL(string: "https://example.com")!))
        await store.receive(\.browserOpenResponse)
    }

    func testCheckDeleteAllData() async {
        let store = TestStore(
            initialState: InfoReducer.State()
        ) {
            InfoReducer()
        }

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
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
    }

    func testDeleteAllDataSuccess() async {
        let databaseClient = DatabaseClient(
            fetchHistories: { _ in [] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: {}
        )
        let store = TestStore(
            initialState: InfoReducer.State()
        ) {
            InfoReducer()
                .dependency(databaseClient)
        }

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
                        action: .deleteAllData,
                        label: {
                            TextState(L10n.Alert.Button.Title.delete)
                        }
                    )
                }
            )
        }
        await store.send(.alert(.presented(.deleteAllData)))
        await store.receive(\.deleteAllDataResponse)
    }

    func testDeleteAllDataFailure() async {
        enum Error: Swift.Error {
            case delete
        }

        let databaseClient = DatabaseClient(
            fetchHistories: { _ in [] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: { throw Error.delete }
        )
        let store = TestStore(
            initialState: InfoReducer.State()
        ) {
            InfoReducer()
                .dependency(databaseClient)
        }

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
                        action: .deleteAllData,
                        label: {
                            TextState(L10n.Alert.Button.Title.delete)
                        }
                    )
                }
            )
        }
        await store.send(.alert(.presented(.deleteAllData)))
        await store.receive(\.error.deleteAllData) {
            $0.alert = AlertState {
                TextState(L10n.Info.Alert.DeletionFailed.Title.message)
            }
        }
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
    }

    func testDeleteAllDataCancel() async {
        let databaseClient = DatabaseClient(
            fetchHistories: { _ in [] },
            addHistory: { _ in },
            updateHistory: { _ in },
            deleteHistory: { _ in },
            deleteAllData: {}
        )
        let store = TestStore(
            initialState: InfoReducer.State()
        ) {
            InfoReducer()
                .dependency(databaseClient)
        }

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
                        action: .deleteAllData,
                        label: {
                            TextState(L10n.Alert.Button.Title.delete)
                        }
                    )
                }
            )
        }
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
    }
}
