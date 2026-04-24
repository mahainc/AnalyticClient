// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AnalyticClient",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .singleTargetLibrary("AnalyticClient"),
        .singleTargetLibrary("AnalyticClientLive"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "AnalyticClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "AnalyticClientLive",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                "AnalyticClient",
            ]
        ),
        .testTarget(
            name: "AnalyticClientTests",
            dependencies: ["AnalyticClient"]
        ),
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
