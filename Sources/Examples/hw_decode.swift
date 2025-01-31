//
//  hw_decode.swift
//  Examples
//
//  Created by sunlubo on 2019/1/14.
//

import SwiftFFmpeg

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

private func decode_write(
  codecCtx: AVCodecContext,
  pkt: AVPacket?,
  hwPixFmt: AVPixelFormat,
  file: UnsafeMutablePointer<FILE>
) throws {
  try codecCtx.sendPacket(pkt)

  while true {
    let frame = AVFrame()
    let swFrame = AVFrame()
    var tmpFrame: AVFrame!

    do {
      try codecCtx.receiveFrame(frame)
    } catch let err as AVError where err == .tryAgain || err == .eof {
      break
    }

    if frame.pixelFormat == hwPixFmt {
      // retrieve data from GPU to CPU
      try swFrame.transferData(from: frame)
      tmpFrame = swFrame
    } else {
      tmpFrame = frame
    }

    let buffer = try AVImage.makePixelBuffer(from: tmpFrame)
    defer { buffer.deallocate() }
    fwrite(buffer.baseAddress, 1, buffer.count, file)

    frame.unref()
  }
}

func hw_decode() throws {
  if CommandLine.argc < 5 {
    print(
      "Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) device_type input_file output_file"
    )
    return
  }

  let deviceTypeName = CommandLine.arguments[2]
  let input = CommandLine.arguments[3]
  let output = CommandLine.arguments[4]

  guard let deviceType = AVHWDeviceType(name: deviceTypeName) else {
    print("Device type \(deviceTypeName) is not supported.")
    print(AVHWDeviceType.supportedDeviceTypes())
    fatalError()
  }

  // open the file to dump raw data
  guard let file = fopen(output, "w+") else {
    fatalError("Could not open \(output).")
  }
  defer { fclose(file) }

  let fmtCtx = try AVFormatContext(url: input)
  try fmtCtx.findStreamInfo()

  // find the video stream information
  let streamIndex = fmtCtx.findBestStream(type: .video)!
  let stream = fmtCtx.streams[streamIndex]

  let decoder = AVCodec.findDecoderById(stream.codecParameters.codecId)!
  var i = 0
  var hwPixFmt = AVPixelFormat.none
  while true {
    guard let config = decoder.hwConfig(at: i) else {
      fatalError("Decoder \(decoder.name) does not support device type \(deviceTypeName).")
    }
    if config.methods.contains(.hwDeviceContext) && config.deviceType == deviceType {
      hwPixFmt = config.pixelFormat
      break
    }
    i += 1
  }

  let decoderCtx = AVCodecContext(codec: decoder)
  decoderCtx.setParameters(stream.codecParameters)
  decoderCtx.getFormat = { ctx, fmts in
    print(fmts)
    if fmts.contains(hwPixFmt) {
      return hwPixFmt
    }
    print("Failed to get HW surface format.")
    return .none
  }

  let deviceCtx = try AVHWDeviceContext(deviceType: deviceType)
  decoderCtx.hwDeviceContext = deviceCtx

  try decoderCtx.openCodec()

  // open the file to dump raw data

  // actual decoding and dump the raw data
  let pkt = AVPacket()
  while let _ = try? fmtCtx.readFrame(into: pkt) {
    defer {
      pkt.unref()
    }

    if pkt.streamIndex == streamIndex {
      try decode_write(codecCtx: decoderCtx, pkt: pkt, hwPixFmt: hwPixFmt, file: file)
    }
  }

  // flush
  try decode_write(codecCtx: decoderCtx, pkt: nil, hwPixFmt: hwPixFmt, file: file)
}
