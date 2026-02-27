//
//  FormReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/04/16.
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
@testable import WebSocketClientPackage
import Testing

@MainActor
struct FormReducerTests {
  @Test
  func testURLChanged() async {
    let store = TestStore(
      initialState: FormReducer.State(),
      reducer: {
        FormReducer()
      },
    )

    await store.send(.urlChanged("wss://echo.websocket.org")) {
      $0.url = URL(string: "wss://echo.websocket.org")
      $0.customHeaders = []
      $0.isConnectButtonDisable = false
    }
  }

  @Test(.dependency(\.uuid, .incrementing))
  func testAddCustomHeader() async {
    let store = TestStore(
      initialState: FormReducer.State(),
      reducer: {
        FormReducer()
      },
    )

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

  @Test(.dependency(\.uuid, .incrementing))
  func testRemoveCustomHeader() async {
    let store = TestStore(
      initialState: FormReducer.State(),
      reducer: {
        FormReducer()
      },
    )

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

  @Test(.dependency(\.uuid, .incrementing))
  func testCustomHeaderNameChanged() async {
    let store = TestStore(
      initialState: FormReducer.State(),
      reducer: {
        FormReducer()
      },
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

  @Test(.dependency(\.uuid, .incrementing))
  func testCustomHeaderValueChanged() async {
    let store = TestStore(
      initialState: FormReducer.State(),
      reducer: {
        FormReducer()
      },
    )

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

  @Test
  func testConnect() async {
    let now = Date()

    await withDependencies {
      $0.uuid = .incrementing
      $0.date = .constant(now)
    } operation: {
      let store = TestStore(
        initialState: FormReducer.State(),
        reducer: {
          FormReducer()
        },
      )

      await store.send(.urlChanged("wss://echo.websocket.org")) {
        $0.url = URL(string: "wss://echo.websocket.org")
        $0.customHeaders = []
        $0.isConnectButtonDisable = false
      }
      await store.send(.connect) {
        let history = HistoryEntity(
          id: .init(0),
          url: URL(string: "wss://echo.websocket.org")!,
          customHeaders: [],
          messages: [],
          isConnectionSuccess: false,
          createdAt: now
        )
        $0.connection = .init(
          url: URL(string: "wss://echo.websocket.org")!,
          history: history
        )
      }
    }
  }
}
