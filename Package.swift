// swift-tools-version:5.2

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
            targets: ["GPXKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.1.2"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "GPXKit",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]),
        .testTarget(
            name: "GPXKitTests",
            dependencies: [
                "GPXKit",
                .product(name: "CustomDump", package: "swift-custom-dump")
            ]),
    ]
)
