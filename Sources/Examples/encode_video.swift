//
//  encode_video.swift
//  Demo
//
//  Created by sunlubo on 2018/7/3.
//

import SwiftFFmpeg

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

private func encode(
  codecCtx: AVCodecContext,
  frame: AVFrame?,
  pkt: AVPacket,
  file: UnsafeMutablePointer<FILE>
) throws {
  if let frame = frame {
    print(String(format: "Send frame %3d", frame.pts))
  }

  // send the frame to the encoder
  try codecCtx.sendFrame(frame)

  while true {
    do {
      try codecCtx.receivePacket(pkt)
    } catch let err as AVError where err == .tryAgain || err == .eof {
      return
    }

    print(String(format: "Write packet %3d (size=%5d)", pkt.pts, pkt.size))

    fwrite(pkt.data, 1, pkt.size, file)

    pkt.unref()
  }
}

func encode_video() throws {
  if CommandLine.argc < 3 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) output_file")
    return
  }

  let output = CommandLine.arguments[2]
  // find the mpeg1video encoder
  let codec = AVCodec.findEncoderByName("mpeg1video")!
  let codecCtx = AVCodecContext(codec: codec)

  // put sample parameters
  codecCtx.bitRate = 400000
  // resolution must be a multiple of two
  codecCtx.width = 352
  codecCtx.height = 288
  // frames per second
  codecCtx.timebase = AVRational(num: 1, den: 25)
  codecCtx.framerate = AVRational(num: 25, den: 1)
  // emit one intra frame every ten frames
  // check frame pict_type before passing frame
  // to encoder, if frame->pict_type is AV_PICTURE_TYPE_I
  // then gop_size is ignored and the output of encoder
  // will always be I frame irrespective to gop_size
  codecCtx.gopSize = 10
  codecCtx.maxBFrames = 1
  codecCtx.pixelFormat = .YUV420P

  try codecCtx.openCodec()

  guard let file = fopen(output, "wb") else {
    fatalError("Could not open \(output)")
  }
  defer { fclose(file) }

  let pkt = AVPacket()
  let frame = AVFrame()
  frame.pixelFormat = codecCtx.pixelFormat
  frame.width = codecCtx.width
  frame.height = codecCtx.height

  try frame.allocBuffer(align: 32)

  // encode 1 second of video
  for i in 0..<25 {
    // make sure the frame data is writable
    try frame.makeWritable()

    // prepare a dummy image
    // Y
    for y in 0..<codecCtx.height {
      for x in 0..<codecCtx.width {
        frame.data[0]![y * Int(frame.linesize[0]) + x] = UInt8(truncatingIfNeeded: x + y + i * 3)
      }
    }

    // Cb and Cr
    for y in 0..<codecCtx.height / 2 {
      for x in 0..<codecCtx.width / 2 {
        frame.data[1]![y * Int(frame.linesize[1]) + x] = UInt8(truncatingIfNeeded: 128 + y + i * 2)
        frame.data[2]![y * Int(frame.linesize[2]) + x] = UInt8(truncatingIfNeeded: 64 + x + i * 5)
      }
    }

    frame.pts = Int64(i)

    // encode the image
    try encode(codecCtx: codecCtx, frame: frame, pkt: pkt, file: file)
  }

  // flush the encoder
  try encode(codecCtx: codecCtx, frame: nil, pkt: pkt, file: file)

  // add sequence end code to have a real MPEG file
  let endcode = [0, 0, 1, 0xb7] as [UInt8]
  fwrite(endcode, 1, endcode.count, file)
}
