// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftFFmpeg",
  platforms: [.iOS(.v9), .macOS(.v10_10), .tvOS(.v10)],
  products: [
    .library(
      name: "SwiftFFmpeg",
      targets: ["SwiftFFmpeg"]
    )
  ],
  targets: [
    .target(
      name: "SwiftFFmpeg",
      dependencies: ["CFFmpeg"]
    ),
    .target(
      name: "CFFmpeg",
      dependencies: [
        "libavcodec",
        "libavdevice",
        "libavfilter",
        "libavformat",
        "libavutil",
        "libswresample",
        "libswscale",
      ],
      linkerSettings: [
        .linkedLibrary("z"),
        .linkedLibrary("bz2"),
        .linkedLibrary("iconv"),
        .linkedLibrary("lzma"),
        .linkedFramework("Security"),
        .linkedFramework("CoreMedia"),
        .linkedFramework("CoreVideo"),
        .linkedFramework("AudioToolbox"),
        .linkedFramework("VideoToolbox"),
        .linkedFramework("OpenGL"),
        .linkedFramework("CoreImage"),
        .linkedFramework("AppKit"),
      ]
    ),
    .binaryTarget(
      name: "libavcodec",
      url: "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libavcodec.zip?raw=true",
      checksum: "97f406b33946c1ab941af7dd02991e5cc3703779bb018de8ff265eb7a6d236fa"
    ),
    .binaryTarget(
      name: "libavdevice",
      url:
        "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libavdevice.zip?raw=true",
      checksum: "87738dff91380bd23de288e8702f0aa5511d80895c0974daba13dc117bdd599c"
    ),
    .binaryTarget(
      name: "libavfilter",
      url:
        "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libavfilter.zip?raw=true",
      checksum: "cb9b72b3cd923c9b065041cf6a87e164264f16eb282ea338b15bdae6dd5a3d15"
    ),
    .binaryTarget(
      name: "libavformat",
      url:
        "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libavformat.zip?raw=true",
      checksum: "9def922d249207ed7be7aebdab7bbd2ff3bc41187dcb0bd77c8e216630407e00"
    ),
    .binaryTarget(
      name: "libavutil",
      url: "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libavutil.zip?raw=true",
      checksum: "3ca05b51466e4fec332b5c1c607b228a67f4eb7a89e09944d19550474214f4e2"
    ),
    .binaryTarget(
      name: "libswresample",
      url:
        "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libswresample.zip?raw=true",
      checksum: "76aa9805c67a040a729eee4599162a982f4bbd2609e7c92b7a3c589159259a7a"
    ),
    .binaryTarget(
      name: "libswscale",
      url: "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libswscale.zip?raw=true",
      checksum: "b5e47c27f44c6818cc11a41fe43535e7bdb25d171a0b5c4984b52b303c7e53b1"
    ),
    .target(
      name: "SwiftFFmpegExamples",
      dependencies: ["SwiftFFmpeg"]
    ),
    .testTarget(
      name: "SwiftFFmpegTests",
      dependencies: ["SwiftFFmpeg"]
    ),
  ]
)
