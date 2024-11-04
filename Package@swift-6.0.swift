// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "GPXKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .watchOS(.v6),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "GPXKit",
            targets: ["GPXKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.2")
    ],
    targets: [
        .target(
            name: "GPXKit",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),
        .testTarget(
            name: "GPXKitTests",
            dependencies: [
                "GPXKit",
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "Numerics", package: "swift-numerics")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: [
        .enableUpcomingFeature("ExistentialAny")
    ])
}
