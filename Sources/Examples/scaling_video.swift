//
//  scaling_video.swift
//  Examples
//
//  Created by sunlubo on 2018/7/12.
//

import Foundation
import SwiftFFmpeg

// prepare a dummy image
private func fill_yuv_image(image: AVImage, frameIndex: Int) {
  // Y
  for y in 0..<image.height {
    for x in 0..<image.width {
      image.data[0]![y * Int(image.linesizes[0]) + x] = UInt8(
        truncatingIfNeeded: x + y + frameIndex * 3)
    }
  }

  // Cb and Cr
  for y in 0..<image.height / 2 {
    for x in 0..<image.width / 2 {
      image.data[1]![y * Int(image.linesizes[1]) + x] = UInt8(
        truncatingIfNeeded: 128 + y + frameIndex * 2)
      image.data[2]![y * Int(image.linesizes[2]) + x] = UInt8(
        truncatingIfNeeded: 64 + x + frameIndex * 5)
    }
  }
}

func scaling_video() throws {
  if CommandLine.argc < 4 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) output_file output_size")
    return
  }

  let output = CommandLine.arguments[2]
  let videoSize = CommandLine.arguments[3]

  guard let file = fopen(output, "wb") else {
    fatalError("Could not open \(output).")
  }
  defer { fclose(file) }

  // source
  let srcW = 320
  let srcH = 240
  let srcPixFmt = AVPixelFormat.YUV420P

  // destination
  let dstW = Int(videoSize.split(separator: "x")[0]) ?? 640
  let dstH = Int(videoSize.split(separator: "x")[1]) ?? 480
  let dstPixFmt = AVPixelFormat.RGB24

  // create scaling context
  guard
    let swsCtx = SwsContext(
      srcWidth: srcW,
      srcHeight: srcH,
      srcPixelFormat: srcPixFmt,
      dstWidth: dstW,
      dstHeight: dstH,
      dstPixelFormat: dstPixFmt,
      flags: .bilinear
    )
  else {
    fatalError(
      "Impossible to create scale context for the conversion fmt:\(srcPixFmt.name) s:\(srcW)x\(srcH) -> fmt:\(dstPixFmt.name) s:\(dstW)x\(dstH)"
    )
  }

  // allocate source and destination image buffers
  let srcImage = AVImage(width: srcW, height: srcH, pixelFormat: srcPixFmt)
  let dstImage = AVImage(width: dstW, height: dstH, pixelFormat: dstPixFmt)

  for i in 0..<100 {
    // generate synthetic video
    fill_yuv_image(image: srcImage, frameIndex: i)

    // convert to destination format
    try srcImage.reformat(using: swsCtx, to: dstImage)

    // write scaled image to file
    fwrite(dstImage.data[0], 1, dstImage.size, file)
  }

  print("Scaling succeeded. Play the output file with the command:")
  print("ffplay -f rawvideo -pixel_format \(dstPixFmt.name) -video_size \(dstW)x\(dstH) \(output)")
}
