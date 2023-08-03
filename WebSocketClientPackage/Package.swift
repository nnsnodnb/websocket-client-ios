// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebSocketClientPackage",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "WebSocketClientPackage",
            targets: ["WebSocketClientPackage"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "10.9.0"),
        .package(url: "https://github.com/mono0926/LicensePlist.git", exact: "3.24.9"),
        .package(url: "https://github.com/vsanthanam/SafariView.git", exact: "1.0.0"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", exact: "4.1.1"),
        .package(url: "https://github.com/BookBeat/SwiftGenPlugin.git", branch: "xcodeproject-support"),
        .package(url: "https://github.com/realm/SwiftLint.git", exact: "0.51.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation.git", exact: "0.7.1"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "0.52.0"),
    ],
    targets: [
        .target(
            name: "WebSocketClientPackage",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "FirebaseAnalyticsSwift",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "SafariView",
                    package: "SafariView"
                ),
                .product(
                    name: "SFSafeSymbols",
                    package: "SFSafeSymbols"
                ),
                .product(
                    name: "SwiftUINavigation",
                    package: "swiftui-navigation"
                ),
            ],
            resources: [
                .copy("Resources/AppIcons"),
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint"),
            ]
        ),
        .testTarget(
            name: "WebSocketClientPackageTests",
            dependencies: [
                "WebSocketClientPackage",
            ]
        ),
    ]
)
