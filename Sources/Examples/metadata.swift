//
//  metadata.swift
//  Demo
//
//  Created by sunlubo on 2018/7/5.
//

import SwiftFFmpeg

func metadata() throws {
  if CommandLine.argc < 3 {
    print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input_file")
    return
  }

  let input = CommandLine.arguments[2]
  let fmtCtx = try AVFormatContext(url: input)
  try fmtCtx.findStreamInfo()

  for (k, v) in fmtCtx.metadata {
    print("\(k): \(v)")
  }
}
