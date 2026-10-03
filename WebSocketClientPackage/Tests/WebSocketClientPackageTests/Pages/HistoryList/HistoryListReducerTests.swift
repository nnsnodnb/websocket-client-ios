//
//  HistoryListReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
import Testing
@testable import WebSocketClientPackage

@MainActor
struct HistoryListReducerTests {
  @Test
  func testDeleteHistorySuccess() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )

    await withDependencies {
      $0.database.fetchHistories = { _, _ in [history] }
    } operation: {
      let store = TestStore(
        initialState: HistoryListReducer.State(),
        reducer: {
          HistoryListReducer()
        },
      )

      await store.send(.fetch)
      await store.receive(\.internalAction.fetchResponse, [history]) {
        $0.histories = .init(uniqueElements: [history])
      }

      // delete success
      await store.send(.deleteHistory(.init(integer: 0)))
      await store.receive(\.internalAction.deleteHistoryResponse, history) {
        $0.histories = .init(uniqueElements: [])
      }
    }
  }

  @Test
  func testDeleteHistoryFailure() async throws {
    enum Error: Swift.Error {
      case delete
    }

    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )

    await withDependencies {
      $0.database.fetchHistories = { _, _ in [history] }
      $0.database.deleteHistory = { _ in throw Error.delete }
    } operation: {
      let store = TestStore(
        initialState: HistoryListReducer.State(),
        reducer: {
          HistoryListReducer()
        },
      )

      await store.send(.fetch)
      await store.receive(\.internalAction.fetchResponse, [history]) {
        $0.histories = .init(uniqueElements: [history])
      }

      // delete failure
      await store.send(.deleteHistory(.init(integer: 0)))
      await store.receive(\.internalAction.error.deleteHistory)
    }
  }

  @Test
  func testHistoryDetailDelegateDeleted() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )

    await withDependencies {
      $0.database.fetchHistories = { _, _ in [history] }
    } operation: {
      let store = TestStore(
        initialState: HistoryListReducer.State(
          histories: .init(uniqueElements: [history]),
          historyDetail: .init(history: history),
        ),
        reducer: {
          HistoryListReducer()
        },
      )

      await store.send(.historyDetail(.delegate(.deleted(history)))) {
        $0.histories = .init(uniqueElements: [])
        $0.historyDetail = nil
      }
    }
  }
}
