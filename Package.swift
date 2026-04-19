// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncFormKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AsyncFormKit",
            targets: ["AsyncFormKit"]
        )
    ],
    targets: [
        .target(
            name: "AsyncFormKit"
        ),
        .testTarget(
            name: "AsyncFormKitTests",
            dependencies: ["AsyncFormKit"]
        )
    ]
)
