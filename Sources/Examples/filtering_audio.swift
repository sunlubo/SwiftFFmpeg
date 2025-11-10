//
//  filtering_audio.swift
//  Examples
//
//  Created by sunlubo on 2019/1/16.
//

import SwiftFFmpeg

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

private func print_frame(frame: AVFrame, file: UnsafeMutablePointer<FILE>) throws {
  let n = frame.sampleCount * frame.channelLayout.channelCount
  let data = UnsafeRawPointer(frame.data[0]!).bindMemory(to: UInt16.self, capacity: n)
  for i in 0 ..< n {
    fputc(Int32(data[i] & 0xff), file)
    fputc(Int32(data[i] >> 8 & 0xff), file)
  }
  fflush(file)
}

func filtering_audio() throws {
  if CommandLine.argc < 4 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input_file output_file")
    return
  }

  // open the file to dump raw data
  let output = CommandLine.arguments[3]
  guard let file = fopen(output, "wb") else {
    fatalError("Could not open \(output).")
  }
  defer { fclose(file) }

  let input = CommandLine.arguments[2]
  let fmtCtx = try AVFormatContext(url: input)
  try fmtCtx.findStreamInfo()

  // select the audio stream
  let streamIndex = fmtCtx.findBestStream(type: .audio)!
  let stram = fmtCtx.streams[streamIndex]

  // create decoding context
  let decoder = AVCodec.findDecoderById(stram.codecParameters.codecId)!
  let decoderCtx = AVCodecContext(codec: decoder)
  decoderCtx.setParameters(stram.codecParameters)
  // init the audio decoder
  try decoderCtx.openCodec()

  let buffersrc = AVFilter(name: "abuffer")!
  let buffersink = AVFilter(name: "abuffersink")!
  let inputs = AVFilterInOut()
  let outputs = AVFilterInOut()
  let sampleFmts = [AVSampleFormat.int16]
  let channelLayout = AVChannelLayoutMono
  let sampleRates = [8000] as [CInt]
  let filterGraph = AVFilterGraph()

  // buffer audio source: the decoded frames from the decoder will be inserted here.
  let args = """
  time_base=\(stram.timebase.num)/\(stram.timebase.den):\
  sample_rate=\(decoderCtx.sampleRate):\
  sample_fmt=\(decoderCtx.sampleFormat.name!):\
  channel_layout=\(decoderCtx.channelLayout)
  """
  let buffersrcCtx = try filterGraph.addFilter(buffersrc, name: "in", args: args)

  // buffer audio sink: to terminate the filter chain.
  let buffersinkCtx = try filterGraph.addFilter(buffersink, name: "out", args: nil)
  try buffersinkCtx.set(sampleFmts.map({ $0.rawValue }), forKey: "sample_fmts")
  try buffersinkCtx.set(channelLayout.description, forKey: "ch_layouts")
  try buffersinkCtx.set(sampleRates, forKey: "sample_rates")

  // Set the endpoints for the filter graph.
  // The filter_graph will be linked to the graph described by filters_descr.

  // The buffer source output must be connected to the input pad of
  // the first filter described by filters_descr; since the first
  // filter input label is not specified, it is set to "in" by default.
  outputs.name = "in"
  outputs.filterContext = buffersrcCtx
  outputs.padIndex = 0
  outputs.next = nil

  // The buffer sink input must be connected to the output pad of
  // the last filter described by filters_descr; since the last
  // filter output label is not specified, it is set to "out" by default.
  inputs.name = "out"
  inputs.filterContext = buffersinkCtx
  inputs.padIndex = 0
  inputs.next = nil

  try filterGraph.parse(
    filters: "aresample=8000,aformat=sample_fmts=s16:channel_layouts=mono", inputs: inputs,
    outputs: outputs
  )
  try filterGraph.configure()

  // Print summary of the sink buffer
  // Note: args buffer is reused to store channel layout string
  let outlink = buffersinkCtx.inputs[0]
  print(
    "Output: srate:\(outlink.sampleRate)Hz fmt:\(outlink.sampleFormat) chlayout:\(outlink.channelLayout)"
  )

  let pkt = AVPacket()
  let frame = AVFrame()
  let filterFrame = AVFrame()

  // read all packets
  while let _ = try? fmtCtx.readFrame(into: pkt) {
    defer { pkt.unref() }

    if pkt.streamIndex != streamIndex {
      continue
    }

    try decoderCtx.sendPacket(pkt)

    while true {
      do {
        try decoderCtx.receiveFrame(frame)
      } catch let err as AVError where err == .tryAgain || err == .eof {
        break
      }

      // push the audio data from decoded frame into the filtergraph
      try buffersrcCtx.addFrame(frame, flags: .keepReference)

      // pull filtered audio from the filtergraph
      while true {
        do {
          try buffersinkCtx.getFrame(filterFrame)
        } catch let err as AVError where err == .tryAgain || err == .eof {
          break
        }
        try print_frame(frame: filterFrame, file: file)
        filterFrame.unref()
      }
      frame.unref()
    }
  }

  print("Filtering succeeded. Play the output file with the command:")
  print("ffplay -f s16le -ar 8000 -ac 1 -i \(output)")
}
