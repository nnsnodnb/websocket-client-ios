//
//  InfoPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import BetterSafariView
import ComposableArchitecture
import FirebaseAnalytics
import SFSafeSymbols
import SwiftUI

struct InfoPage: View {
  @Bindable var store: StoreOf<InfoReducer>

  var body: some View {
    NavigationStack {
      form
        .navigationTitle(.infoNavibarTitle)
        .safari(store: $store)
    }
    .alert($store.scope(state: \.alert, action: \.alert))
    .task {
      store.send(.start)
    }
    .analyticsScreen(name: "info-page")
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
          AppIconListPage(
            store: store.scope(
              state: \.appIconList,
              action: \.appIconList
            )
          )
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
          LicenseListPage(
            store: store.scope(
              state: \.licenseList,
              action: \.licenseList,
            )
          )
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
        Analytics.logEvent(
          "url_tapped",
          parameters: [
            "url": url.absoluteString
          ]
        )
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
