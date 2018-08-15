# SwiftFFmpeg

A Swift wrapper for the FFmpeg API

## Installation

You should install [FFmpeg](http://ffmpeg.org/) before use this library, on macOS, you can:

```bash
brew install ffmpeg
```

### Swift Package Manager

SwiftFFmpeg primarily uses [SwiftPM](https://swift.org/package-manager/) as its build tool, so we recommend using that as well. If you want to depend on SwiftFFmpeg in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunlubo/SwiftFFmpeg.git", from: "1.0.0")
]
```

## Usage

```swift
import Foundation
import SwiftFFmpeg

if CommandLine.argc < 2 {
    print("Usage: \(CommandLine.arguments[0]) <input file>")
    exit(1)
}
let input = CommandLine.arguments[1]

let fmtCtx = AVFormatContext()
try fmtCtx.openInput(input)
try fmtCtx.findStreamInfo()

fmtCtx.dumpFormat(isOutput: false)

guard let stream = fmtCtx.videoStream else {
    fatalError("No video stream")
}
guard let codec = AVCodec.findDecoderById(stream.codecpar.codecId) else {
    fatalError("Codec not found")
}
guard let codecCtx = AVCodecContext(codec: codec) else {
    fatalError("Could not allocate video codec context.")
}
try codecCtx.setParameters(stream.codecpar)
try codecCtx.openCodec()

let pkt = AVPacket()
let frame = AVFrame()

while let _ = try? fmtCtx.readFrame(into: pkt) {
    defer { pkt.unref() }

    if pkt.streamIndex != stream.index {
        continue
    }

    try codecCtx.sendPacket(pkt)

    while true {
        do {
            try codecCtx.receiveFrame(frame)
        } catch let err as AVError where err == .EAGAIN || err == .EOF {
            break
        }

        let str = String(
            format: "Frame %3d (type=%@, size=%5d bytes) pts %4lld key_frame %d [DTS %3lld]",
            codecCtx.frameNumber,
            frame.pictType.description,
            frame.pktSize,
            frame.pts,
            frame.isKeyFrame,
            frame.codedPictureNumber
        )
        print(str)

        frame.unref()
    }
}

print("Done.")

```
