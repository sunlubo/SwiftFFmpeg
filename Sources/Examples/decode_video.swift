//
//  decode_video.swift
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

private func saveToPGM(
  _ buf: UnsafeMutablePointer<UInt8>,
  _ wrap: Int,
  _ xsize: Int,
  _ ysize: Int,
  _ filename: String
) {
  let file = fopen(filename, "w")
  defer { fclose(file) }

  let header = String(format: "P5\n%d %d\n%d\n", xsize, ysize, 255)
  fwrite(header, 1, header.utf8.count, file)
  for i in 0..<ysize {
    fwrite(buf.advanced(by: i * wrap), 1, xsize, file)
  }
}

private func decode(
  codecCtx: AVCodecContext,
  frame: AVFrame,
  pkt: AVPacket?,
  output: String
) throws {
  try codecCtx.sendPacket(pkt)

  while true {
    do {
      try codecCtx.receiveFrame(frame)
    } catch let err as AVError where err == .tryAgain || err == .eof {
      break
    }

    let filename = "\(output)-\(codecCtx.frameNumber).pgm"
    print("saving frame \(filename)")

    saveToPGM(frame.data[0]!, Int(frame.linesize[0]), frame.width, frame.height, filename)

    frame.unref()
  }
}

func decode_video() throws {
  if CommandLine.argc < 4 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input_file output_file")
    return
  }

  let input = CommandLine.arguments[2]
  let output = CommandLine.arguments[3]

  let codec = AVCodec.findDecoderById(.H264)!
  let codecCtx = AVCodecContext(codec: codec)
  try codecCtx.openCodec()

  let parser = AVCodecParserContext(codecContext: codecCtx)!

  guard let file = fopen(input, "rb") else {
    print("Could not open \(input).")
    exit(1)
  }
  defer { fclose(file) }

  let pkt = AVPacket()
  let frame = AVFrame()

  let inbufSize = 4096
  let inbuf = UnsafeMutablePointer<UInt8>.allocate(
    capacity: inbufSize + AVConstant.inputBufferPaddingSize)
  inbuf.initialize(to: 0)
  defer { inbuf.deallocate() }

  while feof(file) == 0 {
    // read raw data from the input file
    var size = fread(inbuf, 1, inbufSize, file)
    if size == 0 {
      break
    }

    // use the parser to split the data into frames
    var data = inbuf
    while size > 0 {
      let (buf, bufSize, used) = try parser.parse(data: data, size: size)
      pkt.data = buf
      pkt.size = bufSize

      data = data.advanced(by: used)
      size -= used

      if pkt.size > 0 {
        try decode(codecCtx: codecCtx, frame: frame, pkt: pkt, output: output)
      }
    }
  }

  // flush the decoder
  try decode(codecCtx: codecCtx, frame: frame, pkt: nil, output: output)
}
