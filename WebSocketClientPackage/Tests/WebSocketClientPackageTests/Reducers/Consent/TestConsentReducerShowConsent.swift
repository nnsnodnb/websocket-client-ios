//
//  TestConsentReducerShowConsent.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestConsentReducerShowConsent {
  @Test(
    .dependencies {
      $0.consentInformation.requestConsent = { true }
      $0.consentInformation.load = { _ in }
    }
  )
  func testShowConsentRequestConsentIsRequiredAndLoadSuccess() async throws {
    let store = TestStore(
      initialState: ConsentReducer.State(),
      reducer: {
        ConsentReducer()
      },
    )

    await store.send(.showConsent)
    await store.receive(\.completed)
    await store.receive(\.delegate.completedConsent)
  }

  @Test(
    .dependencies {
      $0.consentInformation.requestConsent = { false }
    }
  )
  func testShowConsentRequesetConsentIsNotRequired() async throws {
    let store = TestStore(
      initialState: ConsentReducer.State(),
      reducer: {
        ConsentReducer()
      },
    )

    await store.send(.showConsent)
    await store.receive(\.completed)
    await store.receive(\.delegate.completedConsent)
  }
}
