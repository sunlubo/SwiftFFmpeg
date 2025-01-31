//
//  remuxing.swift
//  Examples
//
//  Created by sunlubo on 2018/7/5.
//

import Foundation
import SwiftFFmpeg

private func log_packet(_ pkt: AVPacket, fmtCtx: AVFormatContext, tag: String) {
  let timebase = fmtCtx.streams[pkt.streamIndex].timebase
  print(
    """
    \(tag): \
    pts:\(pkt.pts) pts_time:\(Double(pkt.pts) * timebase.toDouble) \
    dts:\(pkt.dts) dts_time:\(Double(pkt.dts) * timebase.toDouble) \
    duration:\(pkt.duration) duration_time:\(Double(pkt.duration) * timebase.toDouble) \
    stream_index:\(pkt.streamIndex)
    """)
}

/// Remux tracks from one container format to another.
func remuxing() throws {
  if CommandLine.argc < 4 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input_file output_file")
    return
  }

  let input = CommandLine.arguments[2]
  let output = CommandLine.arguments[3]

  let ifmtCtx = try AVFormatContext(url: input)
  try ifmtCtx.findStreamInfo()
  ifmtCtx.dumpFormat(isOutput: false)

  let ofmtCtx = try AVFormatContext(format: nil, filename: output)

  var streamMapping = [Int](repeating: 0, count: ifmtCtx.streamCount)
  var streamIndex = 0
  for i in 0..<ifmtCtx.streamCount {
    let istream = ifmtCtx.streams[i]
    let icodecpar = istream.codecParameters

    if icodecpar.mediaType != .audio && icodecpar.mediaType != .video
      && icodecpar.mediaType != .subtitle
    {
      streamMapping[i] = -1
      continue
    }

    streamMapping[i] = streamIndex
    streamIndex += 1

    guard let stream = ofmtCtx.addStream() else {
      fatalError("Failed allocating output stream.")
    }
    stream.codecParameters.copy(from: icodecpar)
    stream.codecParameters.codecTag = 0
  }

  ofmtCtx.dumpFormat(url: output, isOutput: true)

  if !ofmtCtx.outputFormat!.flags.contains(.noFile) {
    try ofmtCtx.openOutput(url: output, flags: .write)
  }

  try ofmtCtx.writeHeader()

  let pkt = AVPacket()
  while let _ = try? ifmtCtx.readFrame(into: pkt) {
    defer {
      pkt.unref()
    }

    let istream = ifmtCtx.streams[pkt.streamIndex]
    let ostreamIndex = streamMapping[pkt.streamIndex]
    if ostreamIndex < 0 {
      continue
    }

    pkt.streamIndex = ostreamIndex
    let ostream = ofmtCtx.streams[ostreamIndex]
    log_packet(pkt, fmtCtx: ofmtCtx, tag: "in ")

    // copy packet
    pkt.pts = AVMath.rescale(
      pkt.pts, istream.timebase, ostream.timebase, rounding: .nearInf, passMinMax: true)
    pkt.dts = AVMath.rescale(
      pkt.dts, istream.timebase, ostream.timebase, rounding: .nearInf, passMinMax: true)
    pkt.duration = AVMath.rescale(pkt.duration, istream.timebase, ostream.timebase)
    pkt.position = -1
    log_packet(pkt, fmtCtx: ofmtCtx, tag: "out")

    try ofmtCtx.interleavedWriteFrame(pkt)
  }

  try ofmtCtx.writeTrailer()
}
