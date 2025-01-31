//
//  filtering_video.swift
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

private var lastPts = AVTimestamp.noPTS

private func display_frame(frame: AVFrame, timebase: AVRational) throws {
  var delay = 0 as Int64
  if frame.pts != AVTimestamp.noPTS {
    if lastPts != AVTimestamp.noPTS {
      // sleep roughly the right amount of time;
      // usleep is in microseconds, just like AV_TIME_BASE.
      delay = AVMath.rescale(frame.pts - lastPts, timebase, AVTimestamp.timebaseQ)
      if delay > 0 && delay < 1_000_000 {
        usleep(useconds_t(delay))
      }
    }
    lastPts = frame.pts
  }

  // Trivial ASCII grayscale display.
  let data = frame.data[0]!
  let linesize = Int(frame.linesize[0])
  puts("\033c")
  for y in 0 ..< frame.height {
    for x in 0 ..< frame.width {
      putchar(Int32(Array(" .-+#".utf8)[Int(data[y * linesize + x]) / 52]))
    }
    putchar(Int32(Array("\n".utf8)[0]))
  }
  fflush(stdout)
}

func filtering_video() throws {
  if CommandLine.argc < 3 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input_file")
    return
  }

  let input = CommandLine.arguments[2]
  let fmtCtx = try AVFormatContext(url: input)
  try fmtCtx.findStreamInfo()

  // select the video stream
  let streamIndex = fmtCtx.findBestStream(type: .video)!
  let stram = fmtCtx.streams[streamIndex]

  // create decoding context
  let decoder = AVCodec.findDecoderById(stram.codecParameters.codecId)!
  let decoderCtx = AVCodecContext(codec: decoder)
  decoderCtx.setParameters(stram.codecParameters)
  // init the video decoder
  try decoderCtx.openCodec()

  let buffersrc = AVFilter(name: "buffer")!
  let buffersink = AVFilter(name: "buffersink")!
  let inputs = AVFilterInOut()
  let outputs = AVFilterInOut()
  let pixFmts = [AVPixelFormat.GRAY8]
  let filterGraph = AVFilterGraph()

  // buffer video source: the decoded frames from the decoder will be inserted here.
  let args = """
  video_size=\(decoderCtx.width)x\(decoderCtx.height):\
  pix_fmt=\(decoderCtx.pixelFormat.rawValue):\
  time_base=\(stram.timebase.num)/\(stram.timebase.den):\
  pixel_aspect=\(decoderCtx.sampleAspectRatio.num)/\(decoderCtx.sampleAspectRatio.den)
  """
  let buffersrcCtx = try filterGraph.addFilter(buffersrc, name: "in", args: args)

  // buffer video sink: to terminate the filter chain.
  let buffersinkCtx = try filterGraph.addFilter(buffersink, name: "out", args: nil)
  try buffersinkCtx.set(pixFmts.map({ $0.rawValue }), forKey: "pix_fmts")

  // Set the endpoints for the filter graph. The filter_graph will be linked to the graph described by filters_descr.

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

  try filterGraph.parse(filters: "scale=78:24,transpose=cclock", inputs: inputs, outputs: outputs)
  try filterGraph.configure()

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

      frame.pts = frame.bestEffortTimestamp

      // push the decoded frame into the filtergraph
      try buffersrcCtx.addFrame(frame, flags: .keepReference)

      // pull filtered frames from the filtergraph
      while true {
        do {
          try buffersinkCtx.getFrame(filterFrame)
        } catch let err as AVError where err == .tryAgain || err == .eof {
          break
        }
        try display_frame(frame: filterFrame, timebase: buffersinkCtx.inputs[0].timebase)
        filterFrame.unref()
      }
      frame.unref()
    }
  }
}
