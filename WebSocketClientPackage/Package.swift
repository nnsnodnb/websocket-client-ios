// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable trailing_comma

import PackageDescription

let package = Package(
  name: "WebSocketClientPackage",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v18),
  ],
  products: [
    .library(
      name: "WebSocketClientPackage",
      targets: ["WebSocketClientPackage"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/stleamist/BetterSafariView.git", .upToNextMajor(from: "2.4.2")),
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "12.10.0")),
    .package(url: "https://github.com/maiyama18/LicensesPlugin.git", .upToNextMajor(from: "0.2.0")),
    .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "7.0.0")),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", .upToNextMajor(from: "0.63.2")),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "1.25.5")),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMajor(from: "1.11.0")),
    .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "13.1.0")),
    .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git", .upToNextMajor(from: "3.1.0")),
  ],
  targets: [
    .target(
      name: "WebSocketClientPackage",
      dependencies: [
        .product(
          name: "BetterSafariView",
          package: "BetterSafariView"
        ),
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
          name: "GoogleMobileAds",
          package: "swift-package-manager-google-mobile-ads"
        ),
        .product(
          name: "GoogleUserMessagingPlatform",
          package: "swift-package-manager-google-user-messaging-platform",
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
        .plugin(name: "LicensesPlugin", package: "LicensesPlugin"),
        .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins"),
      ]
    ),
    .testTarget(
      name: "WebSocketClientPackageTests",
      dependencies: [
        "WebSocketClientPackage",
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
      ]
    ),
  ],
  swiftLanguageModes: [
    .v6,
  ],
)

let debugOtherSwiftFlags = [
  "-Xfrontend", "-warn-long-expression-type-checking=500",
  "-Xfrontend", "-warn-long-function-bodies=500",
  "-strict-concurrency=complete",
  "-enable-actor-data-race-checks",
]

for target in package.targets {
  // swiftSettings
  target.swiftSettings = [
    .unsafeFlags(debugOtherSwiftFlags, .when(configuration: .debug)),
  ]
}
// swiftlint:enable trailing_comma
