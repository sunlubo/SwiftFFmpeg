//
//  AVClass.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/24.
//

import CFFmpeg

// MARK: - AVClass

typealias CAVClass = CFFmpeg.AVClass

public struct AVClass {
  /// The name of the class.
  public var name: String
  /// The options of the class.
  public var options: [AVOption]?
  /// The category of the class. It's used for visualization (like color).
  ///
  /// This is only set if the category is equal for all objects using this class.
  public var category: Category

  init(native: UnsafePointer<CAVClass>) {
    self.name = String(cString: native.pointee.class_name)
    self.category = Category(rawValue: native.pointee.category.rawValue)!
    self.options = values(native.pointee.option, until: { $0.name == nil })?.map(
      AVOption.init(cOption:))
  }
}

// MARK: - AVClass.Category

extension AVClass {
  // https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/log.h#L48
  public enum Category: UInt32 {
    case na
    case input
    case output
    case muxer
    case demuxer
    case encoder
    case decoder
    case filter
    case bitStreamFilter
    case swscaler
    case swresampler
    case deviceVideoOutput = 40
    case deviceVideoInput
    case deviceAudioOutput
    case deviceAudioInput
    case deviceOutput
    case deviceInput

    public var isInputDevice: Bool {
      self == .deviceVideoInput
        || self == .deviceAudioInput
        || self == .deviceInput
    }

    public var isOutputDevice: Bool {
      self == .deviceVideoOutput
        || self == .deviceAudioOutput
        || self == .deviceOutput
    }
  }
}

extension AVClass.Category: CustomStringConvertible {
  public var description: String {
    switch self {
    case .na:
      return "na"
    case .input:
      return "input"
    case .output:
      return "output"
    case .muxer:
      return "muxer"
    case .demuxer:
      return "demuxer"
    case .encoder:
      return "encoder"
    case .decoder:
      return "decoder"
    case .filter:
      return "filter"
    case .bitStreamFilter:
      return "bitStreamFilter"
    case .swscaler:
      return "swscaler"
    case .swresampler:
      return "swresampler"
    case .deviceVideoOutput:
      return "deviceVideoOutput"
    case .deviceVideoInput:
      return "deviceVideoInput"
    case .deviceAudioOutput:
      return "deviceAudioOutput"
    case .deviceAudioInput:
      return "deviceAudioInput"
    case .deviceOutput:
      return "deviceOutput"
    case .deviceInput:
      return "deviceInput"
    }
  }
}

// MARK: - AVClassSupport

public protocol AVClassSupport {
  static var `class`: AVClass { get }

  func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T
}
