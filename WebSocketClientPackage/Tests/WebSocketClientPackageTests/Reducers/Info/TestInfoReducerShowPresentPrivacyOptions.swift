//
//  TestInfoReducerShowPresentPrivacyOptions.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/03/01.
//

import ComposableArchitecture
import DependenciesTestSupport
@testable import WebSocketClientPackage
import Testing

@MainActor
struct TestInfoReducerShowPresentPrivacyOptions {
  @Test
  func testShowPresentPrivacyOptionsIsLoadingConsentForm() async throws {
    let store = TestStore(
      initialState: InfoReducer.State(
        isLoadingConsentForm: true,
      ),
      reducer: {
        InfoReducer()
      },
    )

    await store.send(.showPresentPrivacyOptions)
  }

  @Test(arguments: [true, false])
  func testShowPresentPrivacyOptionsIsNotLoadingConsentForm(visiblePrivacyOptionsRequirements: Bool) async throws {
    await withDependencies {
      guard visiblePrivacyOptionsRequirements else { return }
      $0.consentInformation.load = { _ in }
      $0.consentInformation.presentPrivacyOptions = {}
    } operation: {
      let store = TestStore(
        initialState: InfoReducer.State(
          visiblePrivacyOptionsRequirements: visiblePrivacyOptionsRequirements,
          isLoadingConsentForm: false,
        ),
        reducer: {
          InfoReducer()
        },
      )

      await store.send(.showPresentPrivacyOptions)
      guard visiblePrivacyOptionsRequirements else { return }
      await store.receive(\.loadConsentForm) {
        $0.isLoadingConsentForm = true
      }
      await store.receive(\.loadedConsentForm) {
        $0.isLoadingConsentForm = false
      }
    }
  }
}
