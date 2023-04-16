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
        let version: String
    }

    // MARK: - Action
    enum Action {
        case urlSelected(URL)
        case safariOpen
        case safariDismiss
        case browserOpen(URL)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .urlSelected(url):
                state.url = url
                return .none
            case .safariOpen:
                state.isShowSafari = true
                return .none
            case .safariDismiss:
                state.url = nil
                state.isShowSafari = false
                return .none
            case let .browserOpen(url):
                // TODO: UIApplicationをDependencyにする
                guard UIApplication.shared.canOpenURL(url) else { return .none }
                UIApplication.shared.open(url)
                return .none
            }
        }
    }
}
