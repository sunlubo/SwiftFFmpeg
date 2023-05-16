//
//  encode_audio.swift
//  Demo
//
//  Created by sunlubo on 2018/7/3.
//

import Foundation
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
  // send the frame for encoding
  try codecCtx.sendFrame(frame)

  // read all the available output packets (in general there may be any number of them)
  while true {
    do {
      try codecCtx.receivePacket(pkt)
    } catch let err as AVError where err == .tryAgain || err == .eof {
      return
    }

    fwrite(pkt.data, 1, pkt.size, file)
    pkt.unref()
  }
}

func encode_audio() throws {
  if CommandLine.argc < 3 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) output_file")
    return
  }

  let output = CommandLine.arguments[2]
  // find the MP2 encoder
  let codec = AVCodec.findEncoderById(.MP2)!
  let codecCtx = AVCodecContext(codec: codec)

  // set sample parameters
  codecCtx.bitRate = 64000
  codecCtx.sampleFormat = .int16
  codecCtx.sampleRate = 44100
  codecCtx.channelLayout = AVChannelLayoutStereo

  try codecCtx.openCodec()

  guard let file = fopen(output, "wb") else {
    fatalError("Could not open \(output)")
  }
  defer { fclose(file) }

  // packet for holding encoded output
  let pkt = AVPacket()

  // frame containing input raw audio
  let frame = AVFrame()
  frame.sampleCount = codecCtx.frameSize
  frame.sampleFormat = codecCtx.sampleFormat
  frame.channelLayout = codecCtx.channelLayout
  // allocate the data buffers
  try frame.allocBuffer()

  // encode a single tone sound
  var t = 0 as Float
  let tincr = Float(2 * Double.pi * 440 / Double(codecCtx.sampleRate))
  for _ in 0 ..< 200 {
    // make sure the frame is writable -- makes a copy if the encoder kept a reference internally
    try frame.makeWritable()

    let capacity = frame.sampleCount * frame.channelLayout.channelCount
    let samples = UnsafeMutableRawPointer(frame.data[0]!).bindMemory(
      to: UInt16.self, capacity: capacity
    )
    for i in 0 ..< frame.sampleCount {
      let sample = UInt16(truncatingIfNeeded: Int32((sin(Double(t)) * 10000).rounded(.towardZero)))
      for j in 0 ..< frame.channelLayout.channelCount {
        samples[i * 2 + j] = sample
      }
      t += tincr
    }
    try encode(codecCtx: codecCtx, frame: frame, pkt: pkt, file: file)
  }

  // flush the encoder1
  try encode(codecCtx: codecCtx, frame: nil, pkt: pkt, file: file)
}
