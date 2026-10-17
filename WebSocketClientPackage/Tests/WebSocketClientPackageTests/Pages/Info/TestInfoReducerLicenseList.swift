//
//  TestInfoReducerLicenseList.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/24.
//

import ComposableArchitecture
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestInfoReducerLicenseList {
  @Test
  func testDelegatePushLicenseDetail() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(
        destination: .licenseList,
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.licenseList(.delegate(.pushLicenseDetail(LicensesPlugin.licenses[0])))) {
      $0.path[id: 0] = .licenseDetail(.init(license: LicensesPlugin.licenses[0]))
    }
  }
}
