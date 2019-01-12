// swift-tools-version:4.2
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
    targets: [
        .systemLibrary(
            name: "CFFmpeg",
            pkgConfig: "libavformat"
        ),
        .target(
            name: "SwiftFFmpeg",
            dependencies: ["CFFmpeg"]
        ),
        .target(
            name: "SwiftFFmpegExamples",
            dependencies: ["SwiftFFmpeg"],
            path: "Sources/Examples"
        ),
        .testTarget(
            name: "SwiftFFmpegTests",
            dependencies: ["SwiftFFmpeg"]
        )
    ]
)
