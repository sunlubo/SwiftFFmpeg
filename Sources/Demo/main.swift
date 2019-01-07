import Foundation
import SwiftFFmpeg

if CommandLine.argc < 2 {
    print("Usage: \(CommandLine.arguments[0]) <input file>")
    exit(1)
}
let input = CommandLine.arguments[1]

let fmtCtx = try AVFormatContext(url: input)
try fmtCtx.findStreamInfo()

fmtCtx.dumpFormat(isOutput: false)

guard let stream = fmtCtx.videoStream else {
    fatalError("No video stream")
}
guard let codec = AVCodec.findDecoderById(stream.codecParameters.codecId) else {
    fatalError("Codec not found")
}
let codecCtx = AVCodecContext(codec: codec)
codecCtx.setParameters(stream.codecParameters)
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
        } catch let err as AVError where err == .tryAgain || err == .eof {
            break
        }

        let str = String(
            format: "Frame %3d (type=%@, size=%5d bytes) pts %4lld key_frame %d [DTS %3lld]",
            codecCtx.frameNumber,
            frame.pictureType.description,
            frame.pktSize,
            frame.pts,
            frame.isKeyFrame,
            frame.dts
        )
        print(str)

        frame.unref()
    }
}

print("Done.")
