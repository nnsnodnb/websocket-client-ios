//
//  TestHistoryDetailReducerAlert.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/24.
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestHistoryDetailReducerAlert {
  @Test(
    .dependencies {
      $0.database.deleteHistory = { _ in }
    }
  )
  func testSuccess() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )

    let store = TestStore(
      initialState: HistoryDetailReducer.State(
        history: history,
        alert: AlertState(
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
        ),
      ),
      reducer: {
        HistoryDetailReducer()
      },
    )

    await store.send(.alert(.presented(.confirm))) {
      $0.alert = nil
    }
    await store.receive(\.deleteResponse)
    await store.receive(\.delegate.deleted)
  }

  @Test
  func testFailure() async throws {
    enum Error: Swift::Error {
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
      $0.database.deleteHistory = { _ in throw Error.delete }
    } operation: {
      let store = TestStore(
        initialState: HistoryDetailReducer.State(
          history: history,
          alert: AlertState(
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
          ),
        ),
        reducer: {
          HistoryDetailReducer()
        },
      )

      await store.send(.alert(.presented(.confirm))) {
        $0.alert = nil
      }
      await store.receive(\.error.delete) {
        $0.alert = AlertState(
          title: {
            TextState(.historyDetailAlertDeletionFailedTitleMessage)
          },
        )
      }
    }
  }

  @Test
  func testCancel() async throws {
    let history = HistoryEntity(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: true,
      createdAt: .init()
    )

    let store = TestStore(
      initialState: HistoryDetailReducer.State(
        history: history,
        alert: AlertState(
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
        ),
      ),
      reducer: {
        HistoryDetailReducer()
      },
    )

    await store.send(.alert(.dismiss)) {
      $0.alert = nil
    }
  }
}
