//
//  AppIconListReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/04.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct AppIconListReducer {
    // MARK: - State
    public struct State: Equatable {
        let appIcons: [AppIcon] = AppIcon.allCases

        // MARK: - AppIcon
        public struct AppIcon: Equatable, CaseIterable {
            // MARK: - Properties
            static let `default`: Self = .init(
                displayName: L10n.AppIconList.Content.Title.default,
                image: Image(.icDefaultIcon),
                name: nil
            )
            static let yellow: Self = .init(
                displayName: L10n.AppIconList.Content.Title.yellow,
                image: Image(.icYellowIcon),
                name: "AppIcon-Yellow"
            )
            static let red: Self = .init(
                displayName: L10n.AppIconList.Content.Title.red,
                image: Image(.icRedIcon),
                name: "AppIcon-Red"
            )
            static let blue: Self = .init(
                displayName: L10n.AppIconList.Content.Title.blue,
                image: Image(.icBlueIcon),
                name: "AppIcon-Blue"
            )
            static let purple: Self = .init(
                displayName: L10n.AppIconList.Content.Title.purple,
                image: Image(.icPurpleIcon),
                name: "AppIcon-Purple"
            )
            static let black: Self = .init(
                displayName: L10n.AppIconList.Content.Title.black,
                image: Image(.icBlackIcon),
                name: "AppIcon-Black"
            )
            static let white: Self = .init(
                displayName: L10n.AppIconList.Content.Title.white,
                image: Image(.icWhiteIcon),
                name: "AppIcon-White"
            )

            public static var allCases: [Self] {
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
    public enum Action: Equatable {
        case appIconChanged(State.AppIcon)
        case setAlternateIconNameResponse
        case error
    }

    @Dependency(\.application)
    var application

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case let .appIconChanged(appIcon):
                return .run(
                    operation: { send in
                        try await application.setAlternateIconName(appIcon.name)
                        await send(.setAlternateIconNameResponse)
                        Logger.debug("Changed app icon")
                    },
                    catch: { error, send in
                        await send(.error)
                        Logger.error("Failed changing app icon: \(error)")
                    }
                )
            case .setAlternateIconNameResponse:
                return .none
            case .error:
                return .none
            }
        }
    }
}
