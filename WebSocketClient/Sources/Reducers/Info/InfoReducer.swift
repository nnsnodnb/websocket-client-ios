//
//  InfoReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/16.
//

import ComposableArchitecture
import Foundation
import UIKit

struct InfoReducer: ReducerProtocol {
    // MARK: - State
    struct State: Equatable {
        var isShowSafari = false
        var url: URL?
        var version: String = ""
        var appIconList: AppIconListReducer.State = .init()
    }

    // MARK: - Action
    enum Action: Equatable {
        case start
        case urlSelected(URL)
        case safariOpen
        case safariDismiss
        case browserOpen(URL)
        case browserOpenResponse(TaskResult<Bool>)
        case appIconList(AppIconListReducer.Action)
    }

    @Dependency(\.application) var application
    @Dependency(\.bundle) var bundle

    var body: some ReducerProtocol<State, Action> {
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
            }
        }
        Scope(state: \.appIconList, action: /Action.appIconList) {
            AppIconListReducer()
        }
    }
}
