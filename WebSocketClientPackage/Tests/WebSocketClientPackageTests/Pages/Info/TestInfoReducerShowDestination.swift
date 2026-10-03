//
//  TestInfoReducerShowDestination.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/24.
//

import ComposableArchitecture
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestInfoReducerShowDestination {
  @Test
  func testAppIconList() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.showDestination(.appIconList)) {
      $0.destination = .appIconList
    }
  }

  @Test
  func testLicenseList() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.showDestination(.licenseList)) {
      $0.destination = .licenseList
    }
  }

  @Test
  func testAlreadySetLicenseListAndPathIsNotEmpty() async throws {
    var path: StackState<InfoReducer.Path.State> = .init()
    path.append(.licenseDetail(.init(license: LicensesPlugin.licenses[0])))

    let store = TestStore(
      initialState: InfoReducer.State(
        destination: .licenseList,
        path: path,
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.showDestination(.licenseList)) {
      $0.path = .init()
    }
  }
}
