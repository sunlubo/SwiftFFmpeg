//
//  Deprecated.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2020/8/30.
//

import CFFmpeg

extension SwsContext {
  @available(
    *, deprecated, renamed: "SwsContext.isSupportedInput(_:)"
  )
  public static func supportsInput(_ pixFmt: AVPixelFormat) -> Bool {
    isSupportedInput(pixFmt)
  }

  @available(
    *, deprecated, renamed: "SwsContext.isSupportedOutput(_:)"
  )
  public static func supportsOutput(_ pixFmt: AVPixelFormat) -> Bool {
    isSupportedOutput(pixFmt)
  }

  @available(
    *, deprecated, renamed: "SwsContext.isSupportedEndiannessConversion(_:)"
  )
  public static func supportsEndiannessConversion(_ pixFmt: AVPixelFormat) -> Bool {
    isSupportedEndiannessConversion(pixFmt)
  }
}
