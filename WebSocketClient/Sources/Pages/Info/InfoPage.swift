//
//  InfoPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import ComposableArchitecture
import SafariView
import SwiftUI

struct InfoPage: View {
    let store: StoreOf<InfoReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            NavigationStack {
                form(viewStore)
                    .navigationTitle("App Information")
                    .safari(
                        url: viewStore.binding(
                            get: \.url,
                            send: { $0 != nil ? .safariOpen : .safariDismiss }
                        ),
                        safariView: {
                            SafariView(url: $0)
                                .dismissButtonStyle(.close)
                        }
                    )
            }
            .task {
                viewStore.send(.start)
            }
        })
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
                url: URL(string: "https://twitter.com/nnsnodnb")!,
                icon: {
                    Asset.icTwitter.swiftUIImage
                        .resizable()
                },
                text: "Contact Developer",
                action: {
                    viewStore.send(.urlSelected($0))
                }
            )
            urlRow(
                viewStore,
                url: URL(string: "https://github.com/nnsnodnb/websocket-client-ios")!,
                icon: {
                    Asset.icGithub.swiftUIImage
                        .resizable()
                },
                text: "Source codes",
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
                text: "App Review",
                action: {
                    viewStore.send(.browserOpen($0))
                }
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
                    Text("Version")
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("v\(viewStore.version)")
                    .foregroundColor(.secondary)
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
        Button(
            action: {
                action(url)
            },
            label: {
                HStack {
                    HStack(spacing: 12) {
                        icon()
                            .frame(width: 18, height: 18)
                        Text(text)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronRight)
                        .foregroundColor(.secondary)
                        .frame(width: 12, height: 12)
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
