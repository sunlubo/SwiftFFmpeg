//
//  decode_video.swift
//  SwiftFFmpegExamples
//
//  Created by sunlubo on 2019/1/9.
//  Copyright © 2019-2020 sun. All rights reserved.
//

import Foundation
import SwiftFFmpeg

class DecodeVideo {
  var codecContext: AVCodecContext
  var frame = AVFrame()

  init() {
    let codec = AVCodec.findDecoderById(.H264)!
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
  }
}

// MARK: - DecodeVideo + AVCodecParserDelegate

extension DecodeVideo: AVCodecParserDelegate {

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

      var data = Data()
      var header = String(format: "P5\n%d %d\n%d\n", frame.width, frame.height, 255)
      header.withUTF8 { ptr in
        data.append(contentsOf: ptr)
      }
      for i in 0..<frame.height {
        data.append(frame.data[0]!.advanced(by: i * Int(frame.linesize[0])), count: frame.width)
      }

      let filename = "\(CommandLine.arguments[3])-\(codecContext.frameNumber).pgm"
      try data.write(to: URL(string: "file://\(filename)")!)
      print("Save \(filename)")

      frame.unref()
    }
  }
}

func decode_video() throws {
  if CommandLine.argc < 4 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input_file output_file")
    return
  }

  try DecodeVideo().save()
}
