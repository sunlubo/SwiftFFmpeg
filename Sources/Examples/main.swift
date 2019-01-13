//
//  main.swift
//  SwiftFFmpegExamples
//
//  Created by sunlubo on 2019/1/9.
//

import Foundation
import SwiftFFmpeg

if CommandLine.argc < 2 {
    print("""
    USAGE: \(CommandLine.arguments[0]) subcommand
    
    SUBCOMMANDS:
      avio_dir_cmd        API example program to show how to manipulate resources accessed through AVIOContext.
      avio_reading        API example program to show how to read from a custom buffer accessed through AVIOContext.
      decode_video        video decoding with libavcodec API example
      decode_audio        audio decoding with libavcodec API example
      demuxing_decoding   API example program to show how to read frames from an input file.
                          This program reads frames from a file, decodes them, and writes decoded
                          video frames to a rawvideo file named video_output_file, and decoded
                          audio frames to a rawaudio file named audio_output_file.
      encode_video        video encoding with libavcodec API example
      encode_audio        audio encoding with libavcodec API example.
      metadata            example program to demonstrate the use of the libavformat metadata API.
    """)
    exit(1)
}

let subcommand = CommandLine.arguments[1]
switch subcommand {
case "avio_dir_cmd":
    try avio_dir_cmd()
case "avio_reading":
    try avio_reading()
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
case "metadata":
    try metadata()
default:
    ()
}
