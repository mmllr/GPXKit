// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "GPXKit",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "GPXKit",
            targets: ["GPXKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "GPXKit",
            dependencies: []),
        .testTarget(
            name: "GPXKitTests",
            dependencies: ["GPXKit"]),
    ]
)
