//
//  InfoReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import CasePaths
import ComposableArchitecture
import Foundation
import UIKit

@Reducer
public struct InfoReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    var url: URL?
    var version: String = ""
    var visiblePrivacyOptionsRequirements = false
    var isLoadingConsentForm = false
    var appIconList: AppIconListReducer.State = .init()
    var licenseList: LicenseListReducer.State = .init()
    @Presents var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action: Sendable, Equatable {
    case start
    case urlSelected(URL?)
    case browserOpen(URL)
    case browserOpenResponse
    case appIconList(AppIconListReducer.Action)
    case checkDeleteAllData
    case deleteAllDataResponse
    case loadConsentForm
    case loadedConsentForm
    case showPresentPrivacyOptions
    case licenseList(LicenseListReducer.Action)
    case alert(PresentationAction<Alert>)
    case error(Error)

    // MARK: - Alert
    public enum Alert: Sendable, Equatable {
      case deleteAllData
    }

    // MARK: - Error
    @CasePathable
    public enum Error: Swift.Error {
      case browserOpen
      case deleteAllData
    }
  }

  @Dependency(\.application)
  var application
  @Dependency(\.consentInformation)
  var consentInformation
  @Dependency(\.database)
  var databaseClient
  @Dependency(\.bundle)
  var bundle

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .start:
        state.version = bundle.shortVersionString()
        state.visiblePrivacyOptionsRequirements = consentInformation.visiblePrivacyOptionsRequirements()
        return state.visiblePrivacyOptionsRequirements ? .send(.loadConsentForm) : .none
      case .urlSelected(.none):
        state.url = nil
        return .none
      case let .urlSelected(.some(url)):
        state.url = url
        return .none
      case let .browserOpen(url):
        return .run { send in
          guard await application.canOpenURL(url) else { return }
          _ = try await application.open(url)
          await send(.browserOpenResponse)
        }
      case .browserOpenResponse:
        return .none
      case .appIconList:
        return .none
      case .checkDeleteAllData:
        state.alert = AlertState(
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
        return .none
      case .deleteAllDataResponse:
        return .none
      case .loadConsentForm:
        guard state.visiblePrivacyOptionsRequirements else { return .none }
        state.isLoadingConsentForm = true
        return .run(
          operation: { send in
            try await consentInformation.load(true)
            await send(.loadedConsentForm)
          },
        )
      case .loadedConsentForm:
        state.isLoadingConsentForm = false
        return .none
      case .showPresentPrivacyOptions:
        guard state.visiblePrivacyOptionsRequirements && !state.isLoadingConsentForm else {
          return .none
        }
        return .run(
          operation: { send in
            try await consentInformation.presentPrivacyOptions()
            await send(.loadConsentForm)
          },
          catch: { _, send in
            await send(.loadConsentForm)
          },
        )
      case .licenseList:
        return .none
      case .alert(.dismiss):
        state.alert = nil
        return .none
      case .alert(.presented(.deleteAllData)):
        state.alert = nil
        return .run(
          operation: { send in
            try await databaseClient.deleteAllData()
            await send(.deleteAllDataResponse)
          },
          catch: { error, send in
            await send(.error(.deleteAllData))
            Logger.error("Failed deleting all data: \(error)")
          }
        )
      case .alert:
        return .none
      case .error(.deleteAllData):
        state.alert = AlertState {
          TextState(.infoAlertDeletionFailedTitleMessage)
        }
        return .none
      case .error:
        return .none
      }
    }
    Scope(state: \.appIconList, action: \.appIconList) {
      AppIconListReducer()
    }
    Scope(state: \.licenseList, action: \.licenseList) {
      LicenseListReducer()
    }
  }
}
