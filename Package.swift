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
        "libpostproc",
        "libswresample",
        "libswscale",
      ],
      linkerSettings: [
        .linkedLibrary("z"),
        .linkedLibrary("bz2"),
        .linkedLibrary("iconv"),
        .linkedLibrary("lzma"),
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
      checksum: "fd7134a138765bc9c80cc991e032a0229512c5bf0a18c151a9dcec4afa4fad0b"
    ),
    .binaryTarget(
      name: "libavdevice",
      url:
        "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libavdevice.zip?raw=true",
      checksum: "91787692e329cdf60a80d96a42022bc9bd94b42e5c0ba79537313132886e9091"
    ),
    .binaryTarget(
      name: "libavfilter",
      url:
        "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libavfilter.zip?raw=true",
      checksum: "8f87a588508ca40990905e0a6ce904ddc850ab2bc1069802f01e78a87fda8867"
    ),
    .binaryTarget(
      name: "libavformat",
      url:
        "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libavformat.zip?raw=true",
      checksum: "d22e1ebb8c4f1ffc4975c9f3effabea6cde30ebd74dcd8fd1f55fca33d25c0b6"
    ),
    .binaryTarget(
      name: "libavutil",
      url: "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libavutil.zip?raw=true",
      checksum: "46e9c2d1e78272ae349081c8a3f49a357224ef789a9fd954e4e6d3e662eeffd1"
    ),
    .binaryTarget(
      name: "libpostproc",
      url:
        "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libpostproc.zip?raw=true",
      checksum: "e1d3c5f4bef331a3bb0b57762b833faff851917733f42edbf25497983de037a9"
    ),
    .binaryTarget(
      name: "libswresample",
      url:
        "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libswresample.zip?raw=true",
      checksum: "b22f6e1754766dc9691755a9c17a800f63eb7299cba7649091bb26ad982b0c8c"
    ),
    .binaryTarget(
      name: "libswscale",
      url: "https://github.com/sunlubo/SwiftFFmpeg/blob/master/xcframework/libswscale.zip?raw=true",
      checksum: "a6b9201886e8aab5022b557cf0da2d8c5b1f085355d63f15665c4f48e9667a7b"
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
