//
//  demuxing_decoding.swift
//  Examples
//
//  Created by sunlubo on 2018/7/5.
//

import Foundation
import SwiftFFmpeg

private func openCodecContext(fmtCtx: AVFormatContext, mediaType: AVMediaType) throws -> (
  AVCodecContext, Int
) {
  let streamIndex = fmtCtx.findBestStream(type: mediaType)!
  let stream = fmtCtx.streams[streamIndex]
  // find decoder for the stream
  let decoder = AVCodec.findDecoderById(stream.codecParameters.codecId)!
  // Allocate a codec context for the decoder
  let codecCtx = AVCodecContext(codec: decoder)
  // Copy codec parameters from input stream to output codec context
  codecCtx.setParameters(stream.codecParameters)
  // Init the decoders, with or without reference counting
  try codecCtx.openCodec(options: ["refcounted_frames": "1"])

  return (codecCtx, streamIndex)
}

private func decode_video_packet(
  codecCtx: AVCodecContext,
  pkt: AVPacket?,
  frame: AVFrame,
  image: AVImage,
  file: UnsafeMutablePointer<FILE>
) throws {
  try codecCtx.sendPacket(pkt)

  while true {
    do {
      try codecCtx.receiveFrame(frame)
    } catch let err as AVError where err == .tryAgain || err == .eof {
      break
    }

    if frame.width != image.width || frame.height != image.height
      || frame.pixelFormat != image.pixelFormat
    {
      fatalError(
        """
        Error: Width, height and pixel format have to be constant in a rawvideo file,
        but the width, height or pixel format of the input video changed:\n
        old: width = \(image.width), height = \(image.height), format = \(image.pixelFormat)\n
        new: width = \(frame.width), height = \(frame.height), format = \(frame.pixelFormat)
        """)
    }
    print("video frame: \(codecCtx.frameNumber)")

    // copy decoded frame to destination buffer:
    // this is required since rawvideo expects non aligned data
    image.copy(from: frame)
    // write to rawvideo file
    fwrite(image.data[0], 1, image.size, file)

    frame.unref()
  }
}

private func decode_audio_packet(
  codecCtx: AVCodecContext,
  pkt: AVPacket?,
  frame: AVFrame,
  file: UnsafeMutablePointer<FILE>
) throws {
  try codecCtx.sendPacket(pkt)

  while true {
    do {
      try codecCtx.receiveFrame(frame)
    } catch let err as AVError where err == .tryAgain || err == .eof {
      break
    }

    // Write the raw audio data samples of the first plane. This works
    // fine for packed formats (e.g. AV_SAMPLE_FMT_S16). However,
    // most audio decoders output planar audio, which uses a separate
    // plane of audio samples for each channel (e.g. AV_SAMPLE_FMT_S16P).
    // In other words, this code will write only the first audio channel
    // in these cases.
    // You should use libswresample or libavfilter to convert the frame
    // to packed data.
    let unpaddedLinesize = frame.sampleCount * frame.sampleFormat.bytesPerSample
    fwrite(frame.extendedData[0], 1, unpaddedLinesize, file)

    print("audio frame: \(codecCtx.frameNumber)")

    frame.unref()
  }
}

func demuxing_decoding() throws {
  if CommandLine.argc < 4 {
    print(
      "Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input_file video_output_file audio_output_file"
    )
    return
  }

  let input = CommandLine.arguments[2]
  let videoOutput = CommandLine.arguments[3]
  let audioOutput = CommandLine.arguments[4]

  // open input file, and allocate format context
  let fmtCtx = try AVFormatContext(url: input)
  // retrieve stream information
  try fmtCtx.findStreamInfo()
  // dump input information to stderr
  fmtCtx.dumpFormat(isOutput: false)

  let (videoCodecCtx, videoIndex) = try openCodecContext(fmtCtx: fmtCtx, mediaType: .video)
  guard let videoOutputFile = fopen(videoOutput, "wb") else {
    fatalError("Could not open \(videoOutput)")
  }
  defer { fclose(videoOutputFile) }

  // allocate image where the decoded image will be put
  let image = AVImage(
    width: videoCodecCtx.width, height: videoCodecCtx.height, pixelFormat: videoCodecCtx.pixelFormat
  )

  let (audioCodecCtx, audioIndex) = try openCodecContext(fmtCtx: fmtCtx, mediaType: .audio)
  guard let audioOutputFile = fopen(audioOutput, "wb") else {
    fatalError("Could not open \(audioOutput)")
  }
  defer { fclose(audioOutputFile) }

  print("Demuxing video from file '\(input)' into '\(videoOutput)'")
  print("Demuxing audio from file '\(input)' into '\(audioOutput)'")

  let frame = AVFrame()
  let pkt = AVPacket()

  // read frames from the file
  while let _ = try? fmtCtx.readFrame(into: pkt) {
    if pkt.streamIndex == videoIndex {
      try decode_video_packet(
        codecCtx: videoCodecCtx, pkt: pkt, frame: frame, image: image, file: videoOutputFile)
    } else if pkt.streamIndex == audioIndex {
      try decode_audio_packet(
        codecCtx: audioCodecCtx, pkt: pkt, frame: frame, file: audioOutputFile)
    }
    pkt.unref()
  }

  // flush cached frames
  try decode_video_packet(
    codecCtx: videoCodecCtx, pkt: nil, frame: frame, image: image, file: videoOutputFile)
  try decode_audio_packet(codecCtx: audioCodecCtx, pkt: nil, frame: frame, file: audioOutputFile)

  print("Demuxing succeeded.")

  print("Play the output video file with the command:")
  print(
    "ffplay -f rawvideo -pix_fmt \(videoCodecCtx.pixelFormat) -video_size \(videoCodecCtx.width)x\(videoCodecCtx.height) \(videoOutput)"
  )

  print("Play the output audio file with the command:")
  // todo: audio format
  print("ffplay -f f32le -ac 1 -ar \(audioCodecCtx.sampleRate) \(audioOutput)")
}
