//
//  AppIconListReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/04.
//

import ComposableArchitecture
import SwiftUI

public struct AppIconListReducer: Reducer {
    // MARK: - State
    public struct State: Equatable {
        let appIcons: [AppIcon] = AppIcon.allCases

        // MARK: - AppIcon
        public struct AppIcon: Equatable, CaseIterable {
            // MARK: - Properties
            static let `default`: Self = .init(
                displayName: L10n.AppIconList.Content.Title.default,
                image: Asset.icDefaultIcon.swiftUIImage,
                name: nil
            )
            static let yellow: Self = .init(
                displayName: L10n.AppIconList.Content.Title.yellow,
                image: Asset.icYellowIcon.swiftUIImage,
                name: "AppIcon-Yellow"
            )
            static let red: Self = .init(
                displayName: L10n.AppIconList.Content.Title.red,
                image: Asset.icRedIcon.swiftUIImage,
                name: "AppIcon-Red"
            )
            static let blue: Self = .init(
                displayName: L10n.AppIconList.Content.Title.blue,
                image: Asset.icBlueIcon.swiftUIImage,
                name: "AppIcon-Blue"
            )
            static let purple: Self = .init(
                displayName: L10n.AppIconList.Content.Title.purple,
                image: Asset.icPurpleIcon.swiftUIImage,
                name: "AppIcon-Purple"
            )
            static let black: Self = .init(
                displayName: L10n.AppIconList.Content.Title.black,
                image: Asset.icBlackIcon.swiftUIImage,
                name: "AppIcon-Black"
            )
            static let white: Self = .init(
                displayName: L10n.AppIconList.Content.Title.white,
                image: Asset.icWhiteIcon.swiftUIImage,
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
        case setAlternateIconNameResponse(TaskResult<Bool>)
    }

    @Dependency(\.application)
    var application

    public var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case let .appIconChanged(appIcon):
                return .run { send in
                    try await application.setAlternateIconName(appIcon.name)
                    await send(.setAlternateIconNameResponse(.success(true)))
                }
            case .setAlternateIconNameResponse(.success):
                return .none
            case .setAlternateIconNameResponse(.failure):
                return .none
            }
        }
    }
}
