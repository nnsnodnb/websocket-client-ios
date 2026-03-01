//
//  TestInfoReducerAlert.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestInfoReducerAlert {
  @Test(
    .dependencies {
      $0.database.deleteAllData = {}
    }
  )
  func testAlertDeleteAllData() async {
    let store = TestStore(
      initialState: InfoReducer.State(
        alert: AlertState(
          title: {
            TextState(.infoAlertConfirmTitleMessage)
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
              action: .deleteAllData,
              label: {
                TextState(.alertButtonTitleDelete)
              }
            )
          }
        ),
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.alert(.presented(.deleteAllData))) {
      $0.alert = nil
    }
    await store.receive(\.deleteAllDataResponse)
  }

  @Test
  func testAlertDismiss() async {
    let store = TestStore(
      initialState: InfoReducer.State(
        alert: AlertState(
          title: {
            TextState(.infoAlertConfirmTitleMessage)
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
              action: .deleteAllData,
              label: {
                TextState(.alertButtonTitleDelete)
              }
            )
          }
        ),
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.alert(.dismiss)) {
      $0.alert = nil
    }
  }

  @Test
  func testDeleteAllDataFailure() async {
    enum Error: Swift.Error {
      case delete
    }

    await withDependencies {
      $0.database.deleteAllData = { throw Error.delete }
    } operation: {
      let store = TestStore(
        initialState: InfoReducer.State(
          alert: AlertState(
            title: {
              TextState(.infoAlertConfirmTitleMessage)
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
                action: .deleteAllData,
                label: {
                  TextState(.alertButtonTitleDelete)
                }
              )
            }
          ),
        ),
        reducer: {
          InfoReducer()
        },
      )

      await store.send(.alert(.presented(.deleteAllData))) {
        $0.alert = nil
      }
      await store.receive(\.error.deleteAllData) {
        $0.alert = AlertState {
          TextState(.infoAlertDeletionFailedTitleMessage)
        }
      }
    }
  }
}
