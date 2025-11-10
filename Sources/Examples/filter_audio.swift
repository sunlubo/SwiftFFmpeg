//
//  filter_audio.swift
//  Examples
//
//  Created by sunlubo on 2019/1/17.
//

import Foundation
import SwiftFFmpeg

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

private let sampleRate = 48000
private let sampleFormat = AVSampleFormat.floatPlanar
private let channelLayout = AVChannelLayout5Point0
private let frameSize = 1024

/// Construct a frame of audio data to be filtered; this simple example just synthesizes a sine wave.
private func get_input(frame: AVFrame, index: Int) throws {
  // Set up the frame properties and allocate the buffer for the data.
  frame.sampleRate = sampleRate
  frame.sampleFormat = sampleFormat
  frame.channelLayout = channelLayout
  frame.sampleCount = frameSize
  frame.pts = Int64(index * frameSize)

  try frame.allocBuffer()

  // Fill the data for each channel.
  for i in 0..<5 {
    let data = UnsafeMutableRawPointer(frame.extendedData[0]!).bindMemory(
      to: CFloat.self, capacity: frame.sampleCount)
    for j in 0..<frame.sampleCount {
      data[j] = sin(2 * Float.pi * Float(index + j) * Float(i + 1) / Float(frameSize))
    }
  }
}

/// Do something useful with the filtered data: this simple
/// example just prints the MD5 checksum of each plane to stdout.
private func process_output(frame: AVFrame) throws {
  let channels = frame.channelLayout.channelCount
  let planes = frame.sampleFormat.isPlanar ? channels : 1
  let bps = frame.sampleFormat.bytesPerSample
  let planeSize = bps * frame.sampleCount * (frame.sampleFormat.isPlanar ? 1 : channels)
  for i in 0..<planes {
    let checksum = UnsafeBufferPointer(start: frame.extendedData[i], count: planeSize).md5
    print("plane \(i): 0x\(checksum)")
  }
}

/// This example will generate a sine wave audio,
/// pass it through a simple filter chain, and then compute the MD5 checksum of
/// the output data.
///
/// The filter chain it uses is:
///
///     (input) -> abuffer -> volume -> aformat -> abuffersink -> (output)
///
/// - abuffer: This provides the endpoint where you can feed the decoded samples.
/// - volume: In this example we hardcode it to 0.90.
/// - aformat: This converts the samples to the samplefreq, channel layout, and sample format required by the audio device.
/// - abuffersink: This provides the endpoint where you can read the samples after they have passed through the filter chain.
func filter_audio() throws {
  if CommandLine.argc < 3 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) duration")
    return
  }

  guard let duration = Int(CommandLine.arguments[2]), duration > 0 else {
    fatalError("Invalid duration: \(CommandLine.arguments[2])")
  }
  let frameCount = duration * sampleRate / frameSize

  // Set up the filtergraph.

  // Create a new filtergraph, which will contain all the filters.
  let filterGraph = AVFilterGraph()

  // Create the abuffer filter;
  // it will be used for feeding the data into the graph.
  let abuffer = AVFilter(name: "abuffer")!
  let abufferCtx = AVFilterContext(graph: filterGraph, filter: abuffer, name: "src")
  // Set the filter options through the AVOptions API.
  try abufferCtx.set(channelLayout.description, forKey: "channel_layout")
  try abufferCtx.set(sampleFormat.name!, forKey: "sample_fmt")
  try abufferCtx.set(AVRational(num: 1, den: Int32(sampleRate)), forKey: "time_base")
  try abufferCtx.set(sampleRate, forKey: "sample_rate")
  // Now initialize the filter; we pass NULL options, since we have already set all the options above.
  try abufferCtx.initialize()

  // Create volume filter.
  let volume = AVFilter(name: "volume")!
  let volumeCtx = AVFilterContext(graph: filterGraph, filter: volume, name: "volume")
  // A different way of passing the options is as key/value pairs in a dictionary.
  try volumeCtx.initialize(args: ["volume": "0.90"])

  // Create the aformat filter;
  // it ensures that the output is of the format we want.
  let aformat = AVFilter(name: "aformat")!
  let aformatCtx = AVFilterContext(graph: filterGraph, filter: aformat, name: "aformat")
  // A third way of passing the options is in a string of the form key1=value1:key2=value2...
  let args =
    "sample_fmts=\(AVSampleFormat.int16.name!):sample_rates=44100:channel_layouts=\(AVChannelLayoutStereo)"
  try aformatCtx.initialize(args: args)

  // Finally create the abuffersink filter;
  // it will be used to get the filtered data out of the graph.
  let abuffersink = AVFilter(name: "abuffersink")!
  let abuffersinkCtx = AVFilterContext(graph: filterGraph, filter: abuffersink, name: "sink")
  // This filter takes no options.
  try abuffersinkCtx.initialize()

  // Connect the filters;
  // in this simple case the filters just form a linear chain.
  try abufferCtx.link(dst: volumeCtx).link(dst: aformatCtx).link(dst: abuffersinkCtx)

  // Configure the graph.
  try filterGraph.configure()

  let frame = AVFrame()

  // the main filtering loop
  for i in 0..<frameCount {
    // get an input frame to be filtered
    try get_input(frame: frame, index: i)

    // Send the frame to the input of the filtergraph.
    try abufferCtx.addFrame(frame)

    // Get all the filtered output that is available.
    while true {
      do {
        try abuffersinkCtx.getFrame(frame)
      } catch let err as AVError where err == .tryAgain || err == .eof {
        break
      }

      // now do something with our filtered frame
      try process_output(frame: frame)
      frame.unref()
    }
  }
}
