//
//  InfoReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import ComposableArchitecture
import Foundation
import UIKit

@Reducer
public struct InfoReducer {
    // MARK: - State
    public struct State: Equatable {
        var isShowSafari = false
        var url: URL?
        var version: String = ""
        var appIconList: AppIconListReducer.State = .init()
        @PresentationState var alert: AlertState<Action.Alert>?
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
        case deleteAllDataResponse(TaskResult<Bool>)
        case alert(PresentationAction<Alert>)

        // MARK: - Alert
        public enum Alert: Equatable {
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
                return .run { send in
                    let success = await application.open(url)
                    await send(.browserOpenResponse(.success(success)))
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
            case .deleteAllDataResponse(.success):
                return .none
            case let .deleteAllDataResponse(.failure(error)):
                state.alert = AlertState {
                    TextState(L10n.Info.Alert.DeletionFailed.Title.message)
                }
                Logger.error("Failed deleting all data: \(error)")
                return .none
            case .alert(.presented(.deleteAllData)):
                return .run(
                    operation: { send in
                        try await databaseClient.deleteAllData()
                        await send(.deleteAllDataResponse(.success(true)))
                    },
                    catch: { error, send in
                        await send(.deleteAllDataResponse(.failure(error)))
                    }
                )
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        Scope(state: \.appIconList, action: \.appIconList) {
            AppIconListReducer()
        }
    }
}
