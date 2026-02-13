//
//  HistoryDetailReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
@testable import WebSocketClientPackage
import XCTest

final class HistoryDetailReducerTests: XCTestCase {
  private var history: HistoryEntity!

  override func setUp() {
    super.setUp()
    history = .init(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
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

  @MainActor
  func testCheckDelete() async throws {
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history)
    ) {
      HistoryDetailReducer()
    }

    await store.send(.checkDelete) {
      $0.alert = AlertState(
        title: {
          TextState(.historyDetailAlertConfirmTitleMessage)
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState(.alertButtonTitleCancel)
            }
          )
          ButtonState(
            role: .destructive,
            action: .send(.confirm),
            label: {
              TextState(.alertButtonTitleDelete)
            }
          )
        }
      )
    }
  }

  @MainActor
  func testConfirmSuccess() async throws {
    let databaseClient = DatabaseClient(
      fetchHistories: { _ in [] },
      addHistory: { _ in },
      updateHistory: { _ in },
      deleteHistory: { _ in },
      deleteAllData: {}
    )
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history)
    ) {
      HistoryDetailReducer()
        .dependency(databaseClient)
    }

    await store.send(.checkDelete) {
      $0.alert = AlertState(
        title: {
          TextState(.historyDetailAlertConfirmTitleMessage)
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState(.alertButtonTitleCancel)
            }
          )
          ButtonState(
            role: .destructive,
            action: .send(.confirm),
            label: {
              TextState(.alertButtonTitleDelete)
            }
          )
        }
      )
    }
    await store.send(.alert(.presented(.confirm)))
    await store.receive(\.deleteResponse)
    await store.receive(\.deleted)
  }

  @MainActor
  func testConfirmFailure() async throws {
    enum Error: Swift.Error {
      case delete
    }

    let databaseClient = DatabaseClient(
      fetchHistories: { _ in [] },
      addHistory: { _ in },
      updateHistory: { _ in },
      deleteHistory: { _ in throw Error.delete },
      deleteAllData: {}
    )
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history)
    ) {
      HistoryDetailReducer()
        .dependency(databaseClient)
    }

    await store.send(.checkDelete) {
      $0.alert = AlertState(
        title: {
          TextState(.historyDetailAlertConfirmTitleMessage)
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState(.alertButtonTitleCancel)
            }
          )
          ButtonState(
            role: .destructive,
            action: .send(.confirm),
            label: {
              TextState(.alertButtonTitleDelete)
            }
          )
        }
      )
    }
    await store.send(.alert(.presented(.confirm)))
    await store.receive(\.error.delete) {
      $0.alert = AlertState {
        TextState(.historyDetailAlertDeletionFailedTitleMessage)
      }
    }
    await store.send(.alert(.dismiss)) {
      $0.alert = nil
    }
  }

  @MainActor
  func testConfirmCancel() async throws {
    let databaseClient = DatabaseClient(
      fetchHistories: { _ in [] },
      addHistory: { _ in },
      updateHistory: { _ in },
      deleteHistory: { _ in },
      deleteAllData: {}
    )
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history)
    ) {
      HistoryDetailReducer()
        .dependency(databaseClient)
    }

    await store.send(.checkDelete) {
      $0.alert = AlertState(
        title: {
          TextState(.historyDetailAlertConfirmTitleMessage)
        },
        actions: {
          ButtonState(
            role: .cancel,
            label: {
              TextState(.alertButtonTitleCancel)
            }
          )
          ButtonState(
            role: .destructive,
            action: .send(.confirm),
            label: {
              TextState(.alertButtonTitleDelete)
            }
          )
        }
      )
    }
    await store.send(.alert(.dismiss)) {
      $0.alert = nil
    }
  }

  @MainActor
  func testShowCustomHeaderList() async throws {
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history)
    ) {
      HistoryDetailReducer()
    }

    await store.send(.showedCustomHeaderList(true)) {
      $0.isShowCustomHeaderList = true
    }
  }

  @MainActor
  func testDismissCustomHeaderList() async throws {
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history)
    ) {
      HistoryDetailReducer()
    }

    // already dismiss
    await store.send(.showedCustomHeaderList(false))

    // dismiss
    await store.send(.showedCustomHeaderList(true)) {
      $0.isShowCustomHeaderList = true
    }
    await store.send(.showedCustomHeaderList(false)) {
      $0.isShowCustomHeaderList = false
    }
  }
}
