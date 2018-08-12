// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFFmpeg",
    products: [
        .library(
            name: "SwiftFFmpeg",
            targets: ["SwiftFFmpeg"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sunlubo/CFFmpeg.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftFFmpeg"
        ),
        .target(
            name: "SwiftFFmpegDemo",
            dependencies: ["SwiftFFmpeg"],
            path: "Sources/Demo"
        ),
        .testTarget(
            name: "SwiftFFmpegTests",
            dependencies: ["SwiftFFmpeg"]
        )
    ]
)
