// swift-tools-version: 6.3
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
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "12.16.0")),
    .package(url: "https://github.com/maiyama18/LicensesPlugin.git", .upToNextMajor(from: "0.2.0")),
    .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "7.0.0")),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", .upToNextMajor(from: "0.65.0")),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMajor(from: "1.26.1"),
      traits: [
        "ComposableArchitecture2Deprecations",
        // "ComposableArchitecture2DeprecationOverloads",
      ],
    ),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMajor(from: "1.14.1")),
    .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "13.6.0")),
    .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git", .upToNextMajor(from: "3.1.0")),
  ],
  targets: [
    .target(
      name: "WebSocketClientPackage",
      dependencies: [
        .betterSafariView,
        .composableArchitecture,
        .firebaseAnalytics,
        .firebaseCrashlytics,
        .googleMobileAds,
        .googleUserMessagingPlatform,
        .sfSafeSymbols,
      ],
      resources: [
        .process("Model.xcdatamodeld")
      ],
      plugins: [
        .licensesPlugin,
      ],
    ),
    .testTarget(
      name: "WebSocketClientPackageTests",
      dependencies: [
        "WebSocketClientPackage",
        .dependenciesTestSupport,
      ]
    ),
  ],
  swiftLanguageModes: [
    .v6,
  ],
)

// MARK: - Target.Dependency
extension Target.Dependency {
  static var betterSafariView: Self {
    .product(
      name: "BetterSafariView",
      package: "BetterSafariView"
    )
  }

  static var composableArchitecture: Self {
    .product(
      name: "ComposableArchitecture",
      package: "swift-composable-architecture"
    )
  }

  static var dependenciesTestSupport: Self {
    .product(
      name: "DependenciesTestSupport",
      package: "swift-dependencies"
    )
  }

  static var firebaseAnalytics: Self {
    .product(
      name: "FirebaseAnalytics",
      package: "firebase-ios-sdk"
    )
  }

  static var firebaseCrashlytics: Self {
    .product(
      name: "FirebaseCrashlytics",
      package: "firebase-ios-sdk"
    )
  }

  static var googleMobileAds: Self {
    .product(
      name: "GoogleMobileAds",
      package: "swift-package-manager-google-mobile-ads"
    )
  }

  static var googleUserMessagingPlatform: Self {
    .product(
      name: "GoogleUserMessagingPlatform",
      package: "swift-package-manager-google-user-messaging-platform",
    )
  }

  static var sfSafeSymbols: Self {
    .product(
      name: "SFSafeSymbols",
      package: "SFSafeSymbols"
    )
  }
}

// MARK: - Target.PluginUsage
extension Target.PluginUsage {
  static var licensesPlugin: Self {
    .plugin(
      name: "LicensesPlugin",
      package: "LicensesPlugin",
    )
  }

  static var swiftLintBuildToolPlugin: Self {
    .plugin(
      name: "SwiftLintBuildToolPlugin",
      package: "SwiftLintPlugins",
    )
  }
}

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
  // plugins
  target.plugins = (target.plugins ?? []) + [
    .swiftLintBuildToolPlugin,
  ]
}
// swiftlint:enable trailing_comma
