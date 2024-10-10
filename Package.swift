// swift-tools-version:5.9

import PackageDescription

let settings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency"),
]

let package = Package(
    name: "GPXKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .watchOS(.v6),
        .tvOS(.v12),
    ],
    products: [
        .library(
            name: "GPXKit",
            targets: ["GPXKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "GPXKit",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "GPXKitTests",
            dependencies: [
                "GPXKit",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ],
            swiftSettings: settings
        ),
    ]
)

#if swift(>=5.6)
    // Add the documentation compiler plugin if possible
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3")
    )
#endif
