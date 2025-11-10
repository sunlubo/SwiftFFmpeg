//
//  decode_audio.swift
//  Examples
//
//  Created by sunlubo on 2019/1/9.
//

import SwiftFFmpeg

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

private func decode(
  codecCtx: AVCodecContext,
  frame: AVFrame,
  pkt: AVPacket?,
  file: UnsafeMutablePointer<FILE>
) throws {
  try codecCtx.sendPacket(pkt)

  while true {
    do {
      try codecCtx.receiveFrame(frame)
    } catch let err as AVError where err == .tryAgain || err == .eof {
      break
    }

    let dataSize = codecCtx.sampleFormat.bytesPerSample
    for i in 0..<frame.sampleCount {
        for j in 0..<codecCtx.channelLayout.channelCount {
        fwrite(frame.data[j]!.advanced(by: dataSize * i), 1, dataSize, file)
      }
    }
    print(String(format: "write: %3d  %5d", codecCtx.frameNumber, frame.sampleCount))

    frame.unref()
  }
}

func decode_audio() throws {
  if CommandLine.argc < 4 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input_file output_file")
    return
  }

  let input = CommandLine.arguments[2]
  let output = CommandLine.arguments[3]

  guard let inFile = fopen(input, "rb") else {
    fatalError("Could not open \(input).")
  }
  defer { fclose(inFile) }

  guard let outFile = fopen(output, "w") else {
    fatalError("Could not open \(output).")
  }
  defer { fclose(outFile) }

  let codec = AVCodec.findDecoderById(.MP2)!
  let codecCtx = AVCodecContext(codec: codec)
  try codecCtx.openCodec()

  let parser = AVCodecParserContext(codecContext: codecCtx)!

  let pkt = AVPacket()
  let frame = AVFrame()

  let inbufSize = 20480
  let refillThresh = 4096
  let inbuf = UnsafeMutablePointer<UInt8>.allocate(
    capacity: inbufSize + AVConstant.inputBufferPaddingSize)
  inbuf.initialize(to: 0)
  defer { inbuf.deallocate() }

  // decode until eof
  var size = fread(inbuf, 1, inbufSize, inFile)
  var data = inbuf
  while size > 0 {
    // use the parser to split the data into frames
    let (buf, bufSize, used) = try parser.parse(data: data, size: size)
    pkt.data = buf
    pkt.size = bufSize

    data = data.advanced(by: used)
    size -= used

    if pkt.size > 0 {
      try decode(codecCtx: codecCtx, frame: frame, pkt: pkt, file: outFile)
    }

    if size < refillThresh {
      memmove(inbuf, data, size)
      data = inbuf
      let len = fread(data.advanced(by: size), 1, inbufSize - size, inFile)
      if len > 0 {
        size += len
      }
    }
  }

  // flush the decoder
  pkt.data = nil
  pkt.size = 0
  try decode(codecCtx: codecCtx, frame: frame, pkt: pkt, file: outFile)
}
