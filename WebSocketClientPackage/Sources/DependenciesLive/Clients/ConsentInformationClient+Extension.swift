//
//  ConsentInformationClient+Extension.swift
//  WebSocketClientPackage
//
//  Created by Yuya Oka on 2026/09/21.
//

import DependenciesInterfaces
import Foundation
import UserMessagingPlatform

public extension ConsentInformationClient {
  static let google: ConsentInformationClient = .init(
    requestConsent: {
      let parameters = RequestParameters()
      try await ConsentInformation.shared.requestConsentInfoUpdate(with: parameters)
      guard ConsentInformation.shared.consentStatus == .required else { return false }
      let status = ConsentInformation.shared.formStatus == .available
      return status
    },
    load: { @MainActor isForce in
      if isForce {
        try await ConsentForm.load()
      } else {
        try await ConsentForm.loadAndPresentIfRequired(from: nil)
      }
    },
    visiblePrivacyOptionsRequirements: {
      ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    },
    presentPrivacyOptions: { @MainActor in
      let parameters = RequestParameters()
      try await ConsentInformation.shared.requestConsentInfoUpdate(with: parameters)
      guard ConsentInformation.shared.consentStatus == .obtained else { return }
      try await ConsentForm.presentPrivacyOptionsForm(from: nil)
    },
  )
}
