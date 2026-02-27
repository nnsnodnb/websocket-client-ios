//
//  InfoReducerTests.swift
//  WebSocketClientTests
//
//  Created by Yuya Oka on 2023/04/28.
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
@testable import WebSocketClientPackage
import Testing

@MainActor
struct InfoReducerTests {
  @Test(
    .dependencies {
      $0.bundle.shortVersionString = { "1.0.0" }
    }
  )
  func testStart() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.start) {
      $0.version = "1.0.0"
    }
  }

  @Test
  func testURLSelected() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.urlSelected(URL(string: "https://github.com/nnsnodnb/websocket-client-ios")!)) {
      $0.url = URL(string: "https://github.com/nnsnodnb/websocket-client-ios")
    }
    await store.send(.urlSelected(nil)) {
      $0.url = nil
    }
  }

  @Test(
    .dependencies {
      $0.application.canOpenURL = { _ in true }
      $0.application.open = { _ in true }
    }
  )
  func testBrowserOpen() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.browserOpen(URL(string: "https://example.com")!))
    await store.receive(\.browserOpenResponse)
  }

  @Test
  func testCheckDeleteAllData() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.checkDeleteAllData) {
      $0.alert = AlertState(
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
            action: .send(.deleteAllData),
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

  @Test(
    .dependencies {
      $0.database.deleteAllData = {}
    }
  )
  func testDeleteAllDataSuccess() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.checkDeleteAllData) {
      $0.alert = AlertState(
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
      )
    }
    await store.send(.alert(.presented(.deleteAllData)))
    await store.receive(\.deleteAllDataResponse)
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
        initialState: InfoReducer.State(),
        reducer: {
          InfoReducer()
        },
      )

      await store.send(.checkDeleteAllData) {
        $0.alert = AlertState(
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
        )
      }
      await store.send(.alert(.presented(.deleteAllData)))
      await store.receive(\.error.deleteAllData) {
        $0.alert = AlertState {
          TextState(.infoAlertDeletionFailedTitleMessage)
        }
      }
      await store.send(.alert(.dismiss)) {
        $0.alert = nil
      }
    }
  }

  @Test(
    .dependencies {
      $0.database.deleteAllData = {}
    }
  )
  func testDeleteAllDataCancel() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.checkDeleteAllData) {
      $0.alert = AlertState(
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
      )
    }
    await store.send(.alert(.dismiss)) {
      $0.alert = nil
    }
  }
}
