//
//  AVChapter.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2020/7/23.
//

import CFFmpeg

typealias CAVChapter = CFFmpeg.AVChapter

public struct AVChapter {
  /// unique ID to identify the chapter
  public var id: Int
  /// time base in which the start/end timestamps are specified
  public var timeBase: AVRational
  /// chapter start/end time in time_base units
  public var start: Int64
  public var end: Int64
  public var metadata: [String: String]

  internal var native: CAVChapter {
    CAVChapter(
      id: Int32(id), time_base: timeBase, start: start, end: end, metadata: metadata.toAVDict())
  }

  internal init(native: UnsafeMutablePointer<CAVChapter>) {
    self.id = Int(native.pointee.id)
    self.timeBase = native.pointee.time_base
    self.start = native.pointee.start
    self.end = native.pointee.end
    self.metadata = toDictionary(native.pointee.metadata)
  }

  public init(
    id: Int, timeBase: AVRational, start: Int64, end: Int64, metadata: [String: String] = [:]
  ) {
    self.id = id
    self.timeBase = timeBase
    self.start = start
    self.end = end
    self.metadata = metadata
  }
}
