//
//  InfoPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import BetterSafariView
import ComposableArchitecture
import DependenciesInterfaces
import SFSafeSymbols
import SwiftUI

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

  @Dependency(\.analytics)
  var analytics
  @Dependency(\.application)
  var application
  @Dependency(\.consentInformation)
  var consentInformation
  @Dependency(\.database)
  var databaseClient
  @Dependency(\.bundle)
  var bundle

  public var body: some ReducerOf<Self> {
    Scope(\.appIconList, action: \.appIconList) {
      AppIconListReducer()
    }
    Scope(\.licenseList, action: \.licenseList) {
      LicenseListReducer()
    }
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
          await analytics.logEvent(.urlTapped(url))
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
  }
}

struct InfoPage: View {
  @Bindable var store: StoreOf<InfoReducer>

  var body: some View {
    NavigationStack {
      form
        .navigationTitle(.infoNavibarTitle)
        .toolbarTitleDisplayMode(.inlineLarge)
        .modifier {
          if #available(iOS 26.0, *) {
            $0
              .scrollEdgeEffectStyle(.soft, for: .top)
          } else {
            $0
          }
        }
        .safari(store: $store)
    }
    .alert($store.scope(\.alert, action: \.alert))
    .task {
      store.send(.start)
    }
    .analyticsScreen(screenName: .info)
  }

  private var form: some View {
    Form {
      firstSection
      secondSection
      thirdSection
      fourthSection
    }
  }

  private var firstSection: some View {
    Section {
      urlRow(
        url: URL(string: "https://github.com/nnsnodnb/websocket-client-ios")!,
        icon: {
          Image(.icGithub)
            .resizable()
        },
        text: .infoSectionFirstTitleSourceCodes,
        action: {
          store.send(.urlSelected($0))
        }
      )
      urlRow(
        url: URL(string: "https://x.com/nnsnodnb")!,
        icon: {
          Image(.icXTwitetr)
            .resizable()
        },
        text: .infoSectionFirstTitleContactDeveloper,
        action: {
          store.send(.urlSelected($0))
        }
      )
    }
  }

  private var secondSection: some View {
    Section {
      urlRow(
        url: URL(string: "https://itunes.apple.com/jp/app/id6448638174?mt=8&action=write-review")!,
        icon: {
          Image(systemSymbol: .starBubble)
            .resizable()
            .foregroundColor(.purple)
        },
        text: .infoSectionSecondTitleAppReview,
        action: {
          store.send(.browserOpen($0))
        }
      )
      NavigationLink(
        destination: {
          AppIconListPage(store: store.scope(\.appIconList, action: \.appIconList))
        },
        label: {
          HStack(spacing: 12) {
            Image(.icDefaultIcon)
              .resizable()
              .frame(width: 18, height: 18)
              .cornerRadius(4)
            Text(.infoSectionSecondTitleChangeAppIcon)
          }
        }
      )
      buttonRow(
        action: {
          store.send(.checkDeleteAllData)
        },
        image: {
          Image(systemSymbol: .trashSquare)
            .resizable()
            .foregroundColor(.red)
        },
        title: .infoSectionSecondTitleDeleteAllHistoryData
      )
    }
  }

  private var thirdSection: some View {
    Section {
      if store.visiblePrivacyOptionsRequirements {
        buttonRow(
          action: {
            if !store.isLoadingConsentForm {
              store.send(.showPresentPrivacyOptions)
            }
          },
          image: {
            if store.isLoadingConsentForm {
              ProgressView()
                .progressViewStyle(.circular)
            } else {
              Image(systemSymbol: .handRaisedSquareFill)
                .resizable()
                .foregroundStyle(.white, .red.opacity(0.9))
            }
          },
          title: .infoSectionThirdTitlePrivacySettings,
        )
      }
      buttonRow(
        action: {
          store.send(.urlSelected(URL(string: "https://github.com/nnsnodnb/websocket-client-ios/wiki/Privacy-Policy")))
        },
        image: {
          Image(systemSymbol: .handRaisedFill)
            .resizable()
            .scaledToFit()
        },
        title: .infoSectionThirdTitlePrivacyPolicy,
      )
      buttonRow(
        action: {
          store.send(
            .urlSelected(URL(string: "https://nnsnodnb.moe/userdata-external-transmission/?app=moe.nnsnodnb.WebSocketClient"))
          )
        },
        image: {
          Image(systemSymbol: .network)
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color(UIColor.systemCyan))
        },
        title: .infoSectionThirdTitleAboutUserdataExternalTransmission,
      )
    }
  }

  private var fourthSection: some View {
    Section {
      NavigationLink(
        destination: {
          LicenseListPage(store: store.scope(\.licenseList, action: \.licenseList))
        },
        label: {
          HStack(spacing: 12) {
            Image(systemSymbol: .listBulletRectangleFill)
              .resizable()
              .foregroundStyle(.green)
              .frame(width: 18, height: 18)
            Text(.infoSectionFourthTitleLicenses)
          }
        }
      )
      HStack {
        HStack(spacing: 12) {
          Image(systemSymbol: .tagFill)
            .resizable()
            .foregroundColor(.yellow)
            .frame(width: 18, height: 18)
          Text(.infoSectionFourthTitleVersion)
            .foregroundColor(.primary)
        }
        Spacer()
        Text("v\(store.version)")
          .foregroundColor(.secondary)
      }
      HStack(spacing: 12) {
        Image(systemSymbol: .swift)
          .resizable()
          .foregroundColor(.orange)
          .frame(width: 18, height: 18)
        Text(.infoSectionFourthTitleDeveloped)
      }
    }
  }

  private func urlRow(
    url: URL,
    icon: () -> some View,
    text: LocalizedStringResource,
    action: @escaping (URL) -> Void
  ) -> some View {
    buttonRow(
      action: {
        action(url)
      },
      image: icon,
      title: text
    )
  }

  private func buttonRow(
    action: @escaping () -> Void,
    @ViewBuilder image: () -> some View,
    title: LocalizedStringResource,
  ) -> some View {
    Button(
      action: action,
      label: {
        HStack {
          HStack(spacing: 12) {
            image()
              .frame(width: 18, height: 18)
            Text(title)
              .foregroundColor(.primary)
          }
          Spacer()
          Image(systemSymbol: .chevronRight)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.secondary)
            .opacity(0.5)
        }
      }
    )
  }
}

@MainActor
private extension View {
  func safari(store: Bindable<StoreOf<InfoReducer>>) -> some View {
    safariView(
      item: store.url.sending(\.urlSelected),
      content: { url in
        SafariView(url: url)
          .dismissButtonStyle(.close)
      }
    )
  }
}

struct InfoPage_Previews: PreviewProvider {
  static var previews: some View {
    InfoPage(
      store: Store(
        initialState: InfoReducer.State(version: "1.0.0")
      ) {
        InfoReducer()
      }
    )
  }
}
