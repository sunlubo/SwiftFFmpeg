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

func main() throws {
    if CommandLine.argc < 2 {
        print("Usage: \(CommandLine.arguments[0]) <input file>")
        return
    }
    let input = CommandLine.arguments[1]
    
    let fmtCtx = AVFormatContext()
    try fmtCtx.openInput(input)
    try fmtCtx.findStreamInfo()
    
    let stream = fmtCtx.videoStream!
    let codecpar = stream.codecpar
    guard let codec = AVCodec.findDecoderById(codecpar.codecId) else {
        print("Codec not found")
        return
    }
    guard let codecCtx = AVCodecContext(codec: codec) else {
        print("Could not allocate video codec context.")
        return
    }
    try codecCtx.setParameters(stream.codecpar)
    try codecCtx.openCodec()
    
    let pkt = AVPacket()
    let frame = AVFrame()
    
    var num = 50
    while let _ = try? fmtCtx.readFrame(into: pkt) {
        if pkt.streamIndex != stream.index {
            pkt.unref()
            continue
        }
        
        do {
            try codecCtx.sendPacket(pkt)
        } catch {
            print("Error while sending a packet to the decoder: \(error)")
            return
        }
        
        while true {
            do {
                try codecCtx.receiveFrame(frame)
            } catch let err as AVError where err == .EAGAIN || err == .EOF {
                break
            } catch {
                print("Error while receiving a frame from the decoder: \(error)")
                return
            }
            
            let str = String(format: "Frame %2d (type=%@, size=%5d bytes) pts %6lld key_frame %d [DTS %2d]",
                             codecCtx.frameNumber,
                             frame.pictType.description,
                             frame.pktSize,
                             frame.pts,
                             frame.isKeyFrame,
                             frame.codedPictureNumber)
            print(str)
            
            frame.unref()
        }
        
        num -= 1
        if num <= 0 { break }
        
        pkt.unref()
    }
}

do {
    try main()
} catch {
    print(error)
}
```
