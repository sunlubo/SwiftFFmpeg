import Foundation
import SwiftFFmpeg

func main(input: String) throws {
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
    
    let pkt = AVPacket()!
    let frame = AVFrame()!
    
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
    try main(input: "/Users/sun/AV/MR.TAXI.mp4")
} catch {
    print(error)
}
