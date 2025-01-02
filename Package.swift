// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftFFmpeg",
  products: [
    .library(name: "SwiftFFmpeg", targets: ["SwiftFFmpeg"])
  ],
  
  targets: [
    .systemLibrary(name: "CFFmpeg", pkgConfig: "libavcodec"),
    .target(name: "SwiftFFmpeg", dependencies: ["CFFmpeg"]),
    .target(name: "SwiftFFmpegExamples", dependencies: ["SwiftFFmpeg"]),
    .testTarget(name: "SwiftFFmpegTests", dependencies: ["SwiftFFmpeg"]),
  ]
)
