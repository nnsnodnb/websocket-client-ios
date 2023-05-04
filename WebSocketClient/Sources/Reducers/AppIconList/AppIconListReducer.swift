//
//  AppIconListReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/04.
//

import ComposableArchitecture
import SwiftUI

struct AppIconListReducer: ReducerProtocol {
    // MARK: - State
    struct State: Equatable {
        let appIcons: [AppIcon] = AppIcon.allCases

        // MARK: - AppIcon
        struct AppIcon: Equatable, CaseIterable {
            // MARK: - Properties
            static let `default`: Self = .init(
                displayName: L10n.AppIconList.Content.Title.default,
                image: Asset.icDefaultIcon.swiftUIImage,
                name: nil
            )
            static let yellow: Self = .init(
                displayName: L10n.AppIconList.Content.Title.yellow,
                image: Asset.icYellowIcon.swiftUIImage,
                name: "Yellow"
            )
            static let red: Self = .init(
                displayName: L10n.AppIconList.Content.Title.red,
                image: Asset.icRedIcon.swiftUIImage,
                name: "Red"
            )
            static let blue: Self = .init(
                displayName: L10n.AppIconList.Content.Title.blue,
                image: Asset.icBlueIcon.swiftUIImage,
                name: "Blue"
            )
            static let purple: Self = .init(
                displayName: L10n.AppIconList.Content.Title.purple,
                image: Asset.icPurpleIcon.swiftUIImage,
                name: "Purple"
            )
            static let black: Self = .init(
                displayName: L10n.AppIconList.Content.Title.black,
                image: Asset.icBlackIcon.swiftUIImage,
                name: "Black"
            )
            static let white: Self = .init(
                displayName: L10n.AppIconList.Content.Title.white,
                image: Asset.icWhiteIcon.swiftUIImage,
                name: "White"
            )

            static var allCases: [AppIconListReducer.State.AppIcon] {
                return [
                    .default, .yellow, .red, .blue, .purple, .black, .white
                ]
            }

            let displayName: String
            let image: Image
            let name: String?
        }
    }

    // MARK: - Action
    enum Action: Equatable {
        case selection(String?)
        case setAlternateIconNameResponse(TaskResult<Bool>)
    }

    @Dependency(\.application) var application

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case let .selection(name):
                return .task {
                    await .setAlternateIconNameResponse(
                        TaskResult {
                            try await application.setAlternateIconName(name)
                            return true
                        }
                    )
                }
            case .setAlternateIconNameResponse(.success):
                return .none
            case .setAlternateIconNameResponse(.failure):
                return .none
            }
        }
    }
}
