// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "GPXKit",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_12),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "GPXKit",
            targets: ["GPXKit"]),
    ],
    dependencies: [
        .package(name: "Difference", url: "https://github.com/krzysztofzablocki/Difference.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "GPXKit",
            dependencies: []),
        .testTarget(
            name: "GPXKitTests",
            dependencies: [
                "GPXKit", "Difference"
            ]),
    ]
)
