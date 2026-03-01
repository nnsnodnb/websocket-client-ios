//
//  TestInforReducerStart.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestInforReducerStart {
  @Test(
    .dependencies {
      $0.bundle.shortVersionString = { "1.0.0" }
      $0.consentInformation.visiblePrivacyOptionsRequirements = { true }
      $0.consentInformation.load = { _ in }
    }
  )
  func testStartVisiblePrivacyOptionsRequirementsIsTrue() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.start) {
      $0.version = "1.0.0"
      $0.visiblePrivacyOptionsRequirements = true
      $0.isLoadingConsentForm = false
    }
    await store.receive(\.loadConsentForm) {
      $0.isLoadingConsentForm = true
    }
    await store.receive(\.loadedConsentForm) {
      $0.isLoadingConsentForm = false
    }
  }

  @Test(
    .dependencies {
      $0.bundle.shortVersionString = { "1.0.0" }
      $0.consentInformation.visiblePrivacyOptionsRequirements = { false }
    }
  )
  func testStartVisiblePrivacyOptionsRequirementsIsFalse() async {
    let store = TestStore(
      initialState: InfoReducer.State(),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.start) {
      $0.version = "1.0.0"
      $0.visiblePrivacyOptionsRequirements = false
    }
  }
}
