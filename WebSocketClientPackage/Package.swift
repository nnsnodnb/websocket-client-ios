// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable trailing_comma

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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.21.0")),
        .package(url: "https://github.com/mono0926/LicensePlist.git", .upToNextMajor(from: "3.25.1")),
        .package(url: "https://github.com/vsanthanam/SafariUI.git", .upToNextMajor(from: "3.0.2")),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "4.1.1")),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin.git", .upToNextMajor(from: "6.6.2")),
        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.54.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "1.8.0")),
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
                    name: "FirebaseAnalytics",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebaseCrashlytics",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "SafariView",
                    package: "SafariUI"
                ),
                .product(
                    name: "SFSafeSymbols",
                    package: "SFSafeSymbols"
                ),
            ],
            resources: [
                .process("Model.xcdatamodeld")
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
// swiftlint:enable trailing_comma
