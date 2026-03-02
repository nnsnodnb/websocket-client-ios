//
//  TestInfoReducerLoadConsentForm.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestInfoReducerLoadConsentForm {
  @Test(
    .dependencies {
      $0.consentInformation.load = { _ in }
    }
  )
  func testLoadConsentFormVisiblePrivacyOptionsRequirementsIsTrue() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(
        visiblePrivacyOptionsRequirements: true,
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.loadConsentForm) {
      $0.isLoadingConsentForm = true
    }
    await store.receive(\.loadedConsentForm) {
      $0.isLoadingConsentForm = false
    }
  }

  @Test
  func testLoadConsentFormVisiblePrivacyOptionsRequirementsIsFalse() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(
        visiblePrivacyOptionsRequirements: false,
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.loadConsentForm)
  }
}
