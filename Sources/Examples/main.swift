//
//  main.swift
//  Examples
//
//  Created by sunlubo on 2019/1/9.
//

import Foundation
import SwiftFFmpeg

if CommandLine.argc < 2 {
  print(
    """
    USAGE: \(CommandLine.arguments[0]) subcommand

    SUBCOMMANDS:
      decode_video        video decoding with libavcodec API example
      decode_audio        audio decoding with libavcodec API example
      demuxing_decoding   API example program to show how to read frames from an input file.
                          This program reads frames from a file, decodes them, and writes decoded
                          video frames to a rawvideo file named video_output_file, and decoded
                          audio frames to a rawaudio file named audio_output_file.
      encode_video        video encoding with libavcodec API example
      encode_audio        audio encoding with libavcodec API example.
      filter_audio        This example will generate a sine wave audio, pass it through a simple filter chain,
                          and then compute the MD5 checksum of the output data.
      filtering_video     API example for decoding and filtering.
      filtering_audio     API example for audio decoding and filtering.
      http_multiclient    API example program to serve http to multiple clients.
      hw_decode           This example shows how to do HW-accelerated decoding with output frames from the HW video surfaces.
      metadata            example program to demonstrate the use of the libavformat metadata API.
      remuxing            API example program to remux a media file with libavformat and libavcodec.
                          The output format is guessed according to the file extension.
      scaling_video       API example program to show how to scale an image with libswscale.
                          This program generates a series of pictures, rescales them to the given
                          output_size and saves them to an output file named output_file.
      resampling_audio    API example program to show how to resample an audio stream with libswresample.
                          This program generates a series of audio frames, resamples them to a specified
                          output format and rate and saves them to an output file named output_file.
     bsf                  API example about how to use bitstream filter.
     split_stream         API example about how to split stream from a container format.
    """)
  exit(1)
}

let subcommand = CommandLine.arguments[1]
switch subcommand {
case "decode_video":
  try decode_video()
case "decode_audio":
  try decode_audio()
case "demuxing_decoding":
  try demuxing_decoding()
case "encode_video":
  try encode_video()
case "encode_audio":
  try encode_audio()
case "filter_audio":
  try filter_audio()
case "filtering_video":
  try filtering_video()
case "filtering_audio":
  try filtering_audio()
case "http_multiclient":
  try http_multiclient()
case "hw_decode":
  try hw_decode()
case "metadata":
  try metadata()
case "remuxing":
  try remuxing()
case "scaling_video":
  try scaling_video()
case "resampling_audio":
  try resampling_audio()
case "bsf":
  try bsf()
case "split_stream":
  try split_stream()
default:
  ()
}
