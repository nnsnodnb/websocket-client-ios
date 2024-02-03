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
public struct InfoReducer {
    // MARK: - State
    @ObservableState
    public struct State: Equatable {
        var url: URL?
        var version: String = ""
        var appIconList: AppIconListReducer.State = .init()
        @Presents var alert: AlertState<Action.Alert>?
    }

    // MARK: - Action
    public enum Action: Equatable {
        case start
        case urlSelected(URL?)
        case browserOpen(URL)
        case browserOpenResponse
        case appIconList(AppIconListReducer.Action)
        case checkDeleteAllData
        case deleteAllDataResponse
        case alert(PresentationAction<Alert>)
        case error(Error)

        // MARK: - Alert
        public enum Alert: Equatable {
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
    @Dependency(\.databaseClient)
    var databaseClient
    @Dependency(\.bundle)
    var bundle

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .start:
                state.version = bundle.shortVersionString()
                return .none
            case .urlSelected(.none):
                state.url = nil
                return .none
            case let .urlSelected(.some(url)):
                state.url = url
                return .none
            case let .browserOpen(url):
                guard application.canOpenURL(url) else { return .none }
                return .run { send in
                    _ = await application.open(url)
                    await send(.browserOpenResponse)
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
                            action: .deleteAllData,
                            label: {
                                TextState(L10n.Alert.Button.Title.delete)
                            }
                        )
                    }
                )
                return .none
            case .deleteAllDataResponse:
                return .none
            case .alert(.dismiss):
                state.alert = nil
                return .none
            case .alert(.presented(.deleteAllData)):
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
                    TextState(L10n.Info.Alert.DeletionFailed.Title.message)
                }
                return .none
            case .error:
                return .none
            }
        }
        Scope(state: \.appIconList, action: \.appIconList) {
            AppIconListReducer()
        }
    }
}
