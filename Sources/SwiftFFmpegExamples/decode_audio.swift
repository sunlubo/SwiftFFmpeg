//
//  decode_audio.swift
//  SwiftFFmpegExamples
//
//  Created by sunlubo on 2019/1/9.
//  Copyright © 2019-2020 sun. All rights reserved.
//

import Foundation
import SwiftFFmpeg

class DecodeAudio {
  var codecContext: AVCodecContext
  var frame = AVFrame()
  var data = Data()

  init() {
    let codec = AVCodec.findDecoderById(.MP2)!
    codecContext = AVCodecContext(codec: codec)
  }

  func save() throws {
    try codecContext.openCodec()

    let parser = try AVCodecParser(codecContext: codecContext, delegate: self)
    let raw = try Data(contentsOf: URL(string: "file://\(CommandLine.arguments[2])")!)
    raw.withUnsafeBytes { ptr in
      parser.parse(data: ptr.bindMemory(to: UInt8.self))
    }
    // flush
    parser.parse(data: UnsafeBufferPointer(start: nil, count: 0))

    try data.write(to: URL(string: "file://\(CommandLine.arguments[3])")!)
  }
}

// MARK: - DecodeAudio + AVCodecParserDelegate

extension DecodeAudio: AVCodecParserDelegate {

  func packetParsed(_ packet: AVPacket) {
    do {
      try decode(packet)
    } catch {
      print(error)
    }
  }

  func decode(_ packet: AVPacket) throws {
    try codecContext.sendPacket(packet)
    while true {
      do {
        try codecContext.receiveFrame(frame)
      } catch let err as AVError where err == .tryAgain || err == .eof {
        break
      }

      let size = codecContext.sampleFormat.bytesPerSample
      for i in 0..<frame.sampleCount {
        for j in 0..<codecContext.channelCount {
          data.append(
            UnsafeBufferPointer(start: frame.data[j]!.advanced(by: size * i), count: size))
        }
      }

      print("Write \(frame.sampleCount) samples")

      frame.unref()
    }
  }
}

func decode_audio() throws {
  if CommandLine.argc < 4 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input_file output_file")
    return
  }

  try DecodeAudio().save()
}
