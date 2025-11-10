//
//  resampling_audio.swift
//  Examples
//
//  Created by sunlubo on 2018/7/12.
//

import SwiftFFmpeg

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

private func fill_samples(_ samples: AVSamples, _ sampleRate: Int64, _ t: Double) -> Double {
  var t = t
  let tincr = 1.0 / Double(sampleRate)
  let c = 2 * Double.pi * 440.0

  // generate sin tone with 440Hz frequency and duplicated channels
  let capacity = samples.sampleCount * samples.channelCount
  let ptr = UnsafeMutableRawPointer(samples.data[0]!).bindMemory(
    to: Double.self, capacity: capacity
  )
  for i in 0 ..< samples.sampleCount {
    let sample = sin(c * t)
    for j in 0 ..< samples.channelCount {
      ptr[i * samples.channelCount + j] = sample
    }
    t += tincr
  }
  return t
}

func resampling_audio() throws {
  if CommandLine.argc < 3 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) output_file")
    return
  }

  let output = CommandLine.arguments[2]

  guard let file = fopen(output, "wb") else {
    fatalError("Could not open \(output)")
  }
  defer { fclose(file) }

  // source
  let srcChannelLayout = AVChannelLayoutStereo
  let srcChannelCount = srcChannelLayout.channelCount
  let srcSampleRate = 48000 as Int64
  let srcSampleFmt = AVSampleFormat.double
  let srcSampleCount = 1024

  // destination
  let dstChannelLayout = AVChannelLayoutStereo
  let dstChannelCount = dstChannelLayout.channelCount
  let dstSampleRate = 44100 as Int64
  let dstSampleFmt = AVSampleFormat.int16
  var dstSampleCount = 0

  let swrCtx = SwrContext()
  // set options
  try swrCtx.set(srcChannelLayout, forKey: "in_chlayout")
  try swrCtx.set(srcSampleRate, forKey: "in_sample_rate")
  try swrCtx.set(srcSampleFmt, forKey: "in_sample_fmt")
  try swrCtx.set(dstChannelLayout, forKey: "out_chlayout")
  try swrCtx.set(dstSampleRate, forKey: "out_sample_rate")
  try swrCtx.set(dstSampleFmt, forKey: "out_sample_fmt")

  // initialize the resampling context
  try swrCtx.initialize()

  // allocate source and destination samples buffers
  let srcSamples = AVSamples(
    channelCount: srcChannelCount, sampleCount: srcSampleCount, sampleFormat: srcSampleFmt
  )

  // compute the number of converted samples: buffering is avoided
  // ensuring that the output buffer will contain at least all the
  // converted input samples
  var maxDstSampleCount = Int(
    AVMath.rescale(Int64(srcSampleCount), dstSampleRate, srcSampleRate, rounding: .up))
  dstSampleCount = maxDstSampleCount
  // buffer is going to be directly written to a rawaudio file, no alignment
  var dstSamples = AVSamples(
    channelCount: dstChannelCount, sampleCount: dstSampleCount, sampleFormat: dstSampleFmt, align: 0
  )

  var t = 0.0
  repeat {
    // generate synthetic audio
    t = fill_samples(srcSamples, srcSampleRate, t)

    // compute destination number of samples
    dstSampleCount = Int(
      AVMath.rescale(
        Int64(swrCtx.getDelay(srcSampleRate) + srcSampleCount), dstSampleRate, srcSampleRate,
        rounding: .up
      ))

    if dstSampleCount > maxDstSampleCount {
      dstSamples = AVSamples(
        channelCount: dstChannelCount, sampleCount: dstSampleCount, sampleFormat: dstSampleFmt,
        align: 1
      )
      maxDstSampleCount = dstSampleCount
    }

    // convert to destination format
    let sampleCount = try srcSamples.reformat(using: swrCtx, to: dstSamples)

    let (size, _) = try AVSamples.getBufferSize(
      channelCount: dstChannelCount, sampleCount: sampleCount, sampleFormat: dstSampleFmt, align: 1
    )
    fwrite(dstSamples.data[0], 1, size, file)

    print("t:\(t) in:\(srcSampleCount) out:\(sampleCount)")
  } while t < 10

  // TODO: audio format
  print("Resampling succeeded. Play the output file with the command:")
  print(
    "ffplay -f s16le -channel_layout \(dstChannelLayout) -channels \(dstChannelCount) -ar \(dstSampleRate) \(output)"
  )
}
