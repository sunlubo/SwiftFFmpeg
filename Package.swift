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
            path: "Modules",
            pkgConfig: "libavformat",
            providers: [
                .brew(["ffmpeg"]),
                .apt(["ffmpeg-dev"])
            ]),
        .target(
            name: "SwiftFFmpeg",
            dependencies: ["CFFmpeg"]
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
