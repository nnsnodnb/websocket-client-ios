//
//  TestLicenseListReducerPushLicenseDetail.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/24.
//

import ComposableArchitecture
import Testing
@testable import WebSocketClientPackage

@MainActor
struct TestLicenseListReducerPushLicenseDetail {
  @Test
  func testIt() async throws {
    let store = TestStore(
      initialState: LicenseListReducer.State(),
      reducer: {
        LicenseListReducer()
      },
    )

    await store.send(.pushLicenseDetail(LicensesPlugin.licenses[0]))
    await store.receive(\.delegate.pushLicenseDetail, LicensesPlugin.licenses[0])
  }
}
