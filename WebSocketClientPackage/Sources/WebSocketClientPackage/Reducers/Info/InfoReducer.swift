//
//  InfoReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import ComposableArchitecture
import Foundation
import UIKit

public struct InfoReducer: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        var isShowSafari = false
        var url: URL?
        var version: String = ""
        var appIconList: AppIconListReducer.State = .init()
        var alert: AlertState<Action>?
    }

    // MARK: - Action
    public enum Action: Equatable {
        case start
        case urlSelected(URL)
        case safariOpen
        case safariDismiss
        case browserOpen(URL)
        case browserOpenResponse(TaskResult<Bool>)
        case appIconList(AppIconListReducer.Action)
        case checkDeleteAllData
        case deleteAllData
        case deleteAllDataResponse(TaskResult<Bool>)
        case alertDismissed
    }

    @Dependency(\.application)
    var application
    @Dependency(\.databaseClient)
    var databaseClient
    @Dependency(\.bundle)
    var bundle

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
                state.version = bundle.shortVersionString()
                return .none
            case let .urlSelected(url):
                state.url = url
                return .none
            case .safariOpen:
                guard state.url != nil else { return .none }
                state.isShowSafari = true
                return .none
            case .safariDismiss:
                state.url = nil
                state.isShowSafari = false
                return .none
            case let .browserOpen(url):
                guard application.canOpenURL(url) else { return .none }
                return .task {
                    await .browserOpenResponse(
                        TaskResult {
                            await application.open(url)
                        }
                    )
                }
            case .browserOpenResponse:
                return .none
            case .appIconList:
                return .none
            case .checkDeleteAllData:
                state.alert = AlertState(
                    title: {
                        TextState(L10n.Info.Alert.Confirm.Title.message)
                    },
                    actions: {
                        ButtonState(
                            role: .cancel,
                            label: {
                                TextState(L10n.Alert.Button.Title.cancel)
                            }
                        )
                        ButtonState(
                            role: .destructive,
                            action: .send(.deleteAllData),
                            label: {
                                TextState(L10n.Alert.Button.Title.delete)
                            }
                        )
                    }
                )
                return .none
            case .deleteAllData:
                return .task {
                    await .deleteAllDataResponse(
                        TaskResult {
                            try await databaseClient.deleteAllData()
                            return true
                        }
                    )
                }
            case .deleteAllDataResponse(.success):
                return .none
            case .deleteAllDataResponse(.failure):
                state.alert = AlertState {
                    TextState(L10n.Info.Alert.DeletionFailed.Title.message)
                }
                return .none
            case .alertDismissed:
                state.alert = nil
                return .none
            }
        }
        Scope(state: \.appIconList, action: /Action.appIconList) {
            AppIconListReducer()
        }
    }
}
