//
//  InfoPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import ComposableArchitecture
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import SafariView
import SFSafeSymbols
import SwiftUI

struct InfoPage: View {
    let store: StoreOf<InfoReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack {
                form(viewStore)
                    .navigationTitle(L10n.Info.Navibar.title)
                    .safari(
                        url: viewStore.binding(
                            get: \.url,
                            send: { $0 != nil ? .safariOpen : .safariDismiss }
                        ),
                        safariView: {
                            SafariView(url: $0)
                        }
                    )
                    .safariDismissButtonStyle(.close)
            }
            .alert(store.scope(state: \.alert, action: { $0 }), dismiss: .alertDismissed)
            .task {
                viewStore.send(.start)
            }
        })
        .analyticsScreen(name: "info-page")
    }

    private func form(_ viewStore: ViewStoreOf<InfoReducer>) -> some View {
        Form {
            firstSection(viewStore)
            secondSection(viewStore)
            thirdSection(viewStore)
        }
    }

    private func firstSection(_ viewStore: ViewStoreOf<InfoReducer>) -> some View {
        Section {
            urlRow(
                viewStore,
                url: URL(string: "https://github.com/nnsnodnb/websocket-client-ios")!,
                icon: {
                    Asset.icGithub.swiftUIImage
                        .resizable()
                },
                text: L10n.Info.Section.First.Title.sourceCodes,
                action: {
                    viewStore.send(.urlSelected($0))
                }
            )
            urlRow(
                viewStore,
                url: URL(string: "https://twitter.com/nnsnodnb")!,
                icon: {
                    Asset.icTwitter.swiftUIImage
                        .resizable()
                },
                text: L10n.Info.Section.First.Title.contactDeveloper,
                action: {
                    viewStore.send(.urlSelected($0))
                }
            )
        }
    }

    private func secondSection(_ viewStore: ViewStoreOf<InfoReducer>) -> some View {
        Section {
            urlRow(
                viewStore,
                url: URL(string: "https://itunes.apple.com/jp/app/id6448638174?mt=8&action=write-review")!,
                icon: {
                    Image(systemSymbol: .starBubble)
                        .resizable()
                        .foregroundColor(.purple)
                },
                text: L10n.Info.Section.Second.Title.appReview,
                action: {
                    viewStore.send(.browserOpen($0))
                }
            )
            NavigationLink(
                destination: {
                    AppIconListPage(
                        store: store.scope(
                            state: \.appIconList,
                            action: InfoReducer.Action.appIconList
                        )
                    )
                },
                label: {
                    HStack(spacing: 12) {
                        Asset.icDefaultIcon.swiftUIImage
                            .resizable()
                            .frame(width: 18, height: 18)
                            .cornerRadius(4)
                        Text(L10n.Info.Section.Second.Title.changeAppIcon)
                    }
                }
            )
            buttonRow(
                action: {
                    viewStore.send(.checkDeleteAllData)
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

    private func thirdSection(_ viewStore: ViewStoreOf<InfoReducer>) -> some View {
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
                Text("v\(viewStore.version)")
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
        _ viewStore: ViewStoreOf<InfoReducer>,
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

struct InfoPage_Previews: PreviewProvider {
    static var previews: some View {
        InfoPage(
            store: Store(
                initialState: InfoReducer.State(version: "1.0.0"),
                reducer: InfoReducer()
            )
        )
    }
}
