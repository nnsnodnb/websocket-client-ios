//
//  HistoryDetailReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/05/02.
//

import ComposableArchitecture
import Foundation
@testable import WebSocketClientPackage
import Testing

@MainActor
final class HistoryDetailReducerTests {
  private var history: HistoryEntity!

  init() {
    history = .init(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )
  }

  deinit {
    history = nil
  }

  @Test
  func testCheckDelete() async throws {
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history),
      reducer: {
        HistoryDetailReducer()
      },
    )

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

  @Test(
    .dependencies {
      $0.database.deleteHistory = { _ in }
    }
  )
  func testConfirmSuccess() async throws {
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history),
      reducer: {
        HistoryDetailReducer()
      },
    )

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

  @Test
  func testConfirmFailure() async throws {
    enum Error: Swift.Error {
      case delete
    }

    await withDependencies {
      $0.database.deleteHistory = { _ in throw Error.delete }
    } operation: {
      let store = TestStore(
        initialState: HistoryDetailReducer.State(history: history),
        reducer: {
          HistoryDetailReducer()
        },
      )

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
  }

  @Test
  func testConfirmCancel() async throws {
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history),
      reducer: {
        HistoryDetailReducer()
      },
    )

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

  @Test
  func testShowCustomHeaderList() async throws {
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history),
      reducer: {
        HistoryDetailReducer()
      },
    )

    await store.send(.showedCustomHeaderList(true)) {
      $0.isShowCustomHeaderList = true
    }
  }

  @Test
  func testDismissCustomHeaderList() async throws {
    let store = TestStore(
      initialState: HistoryDetailReducer.State(history: history),
      reducer: {
        HistoryDetailReducer()
      },
    )

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
