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
default:
    ()
}
