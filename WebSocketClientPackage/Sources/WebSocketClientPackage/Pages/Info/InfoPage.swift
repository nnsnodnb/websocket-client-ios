//
//  InfoPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import ComposableArchitecture
import FirebaseAnalytics
import Perception
import SafariUI
import SFSafeSymbols
import SwiftUI

@MainActor
struct InfoPage: View {
    @Perception.Bindable var store: StoreOf<InfoReducer>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                form
                    .navigationTitle(L10n.Info.Navibar.title)
                    .safari(store: $store)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .task {
                store.send(.start)
            }
        }
        .analyticsScreen(name: "info-page")
    }

    private var form: some View {
        Form {
            firstSection
            secondSection
            thirdSection
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
                text: L10n.Info.Section.First.Title.sourceCodes,
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
                text: L10n.Info.Section.First.Title.contactDeveloper,
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
                text: L10n.Info.Section.Second.Title.appReview,
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
                        Text(L10n.Info.Section.Second.Title.changeAppIcon)
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
                title: L10n.Info.Section.Second.Title.deleteAllHistoryData
            )
        }
    }

    private var thirdSection: some View {
        Section {
            HStack {
                HStack(spacing: 12) {
                    Image(systemSymbol: .tagFill)
                        .resizable()
                        .foregroundColor(.yellow)
                        .frame(width: 18, height: 18)
                    Text(L10n.Info.Section.Third.Title.version)
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
                Text(L10n.Info.Section.Third.Title.developed)
            }
        }
    }

    private func urlRow(
        url: URL,
        icon: () -> some View,
        text: String,
        action: @escaping (URL) -> Void
    ) -> some View {
        buttonRow(
            action: {
                action(url)
                Analytics.logEvent(
                    "url-tapped",
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
        image: () -> some View,
        title: String
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
    func safari(store: Perception.Bindable<StoreOf<InfoReducer>>) -> some View {
        safari(
            url: store.url.sending(\.urlSelected),
            safariView: {
                SafariView(url: $0)
            }
        )
        .safariDismissButtonStyle(.close)
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
