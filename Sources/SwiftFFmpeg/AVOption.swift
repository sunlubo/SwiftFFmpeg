//
//  AVOption.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/10.
//

import CFFmpeg

// MARK: - AVOption

typealias CAVOption = CFFmpeg.AVOption

public struct AVOption {
  public var name: String
  /// The short English help text about the option.
  public var help: String?
  /// The offset relative to the context structure where the option value is stored.
  /// It should be 0 for named constants.
  public var offset: Int
  public var type: Kind
  /// The default value for scalar options.
  public var defaultValue: Any
  /// The minimum valid value for the option.
  public var min: Double
  /// The maximum valid value for the option.
  public var max: Double
  public var flags: Flag
  /// The logical unit to which the option belongs.
  /// Non-constant options and corresponding named constants share the same unit.
  public var unit: String?

  init(cOption: CAVOption) {
    self.name = String(cString: cOption.name)
    self.help = String(cString: cOption.help)
    self.offset = Int(cOption.offset)
    self.type = Kind(rawValue: cOption.type.rawValue)!
    self.min = cOption.min
    self.max = cOption.max
    self.flags = Flag(rawValue: cOption.flags)
    self.unit = String(cString: cOption.unit)

    switch type {
    case .flags, .int, .int64, .uint64, .const, .pixelFormat, .sampleFormat, .duration, .channelLayout:
      self.defaultValue = cOption.default_val.i64
    case .double, .float, .rational:
      self.defaultValue = cOption.default_val.dbl
    case .bool:
      self.defaultValue = cOption.default_val.i64 != 0 ? "true" : "false"
    case .string, .imageSize, .videoRate, .color:
      self.defaultValue = String(cString: cOption.default_val.str) ?? "nil"
    case .binary:
      self.defaultValue = 0
    case .dict:
      // Cannot set defaults for these types
      self.defaultValue = ""
    }
  }
}

extension AVOption: CustomStringConvertible {
  public var description: String {
    var str = "{name: \"\(name)\", "
    if let help = help {
      str += "help: \"\(help)\", "
    }
    str += "offset: \(offset), type: \(type), "
    if defaultValue is String {
      str += "default: \"\(defaultValue)\", "
    } else {
      str += "default: \(defaultValue), "
    }
    str += "min: \(min), max: \(max), flags: \(flags), "
    if let unit = unit {
      str += "unit: \"\(unit)\""
    } else {
      str.removeLast(2)
    }
    str += "}"
    return str
  }
}

// MARK: - AVOption.Kind

extension AVOption {
  // https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/opt.h#L221
  public enum Kind: UInt32 {
    case flags
    case int
    case int64
    case double
    case float
    case string
    case rational
    /// offset must point to a pointer immediately followed by an int for the length
    case binary
    case dict
    case uint64
    case const
    /// offset must point to two consecutive integers
    case imageSize
    case pixelFormat
    case sampleFormat
    /// offset must point to `AVRational`
    case videoRate
    case duration
    case color
    case channelLayout
    case bool
  }
}

extension AVOption.Kind: CustomStringConvertible {
  public var description: String {
    switch self {
    case .flags:
      return "flags"
    case .int, .int64, .uint64:
      return "integer"
    case .double, .float:
      return "float"
    case .string:
      return "string"
    case .rational:
      return "rational number"
    case .binary:
      return "hexadecimal string"
    case .dict:
      return "dictionary"
    case .const:
      return "const"
    case .imageSize:
      return "image size"
    case .pixelFormat:
      return "pixel format"
    case .sampleFormat:
      return "sample format"
    case .videoRate:
      return "video rate"
    case .duration:
      return "duration"
    case .color:
      return "color"
    case .channelLayout:
      return "channel layout"
    case .bool:
      return "bool"
    }
  }
}

// MARK: - AVOption.Flag

extension AVOption {
  // https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/opt.h#L221
  public struct Flag: OptionSet {
    /// A generic parameter which can be set by the user for muxing or encoding.
    public static let encoding = Flag(rawValue: AV_OPT_FLAG_ENCODING_PARAM)
    /// A generic parameter which can be set by the user for demuxing or decoding.
    public static let decoding = Flag(rawValue: AV_OPT_FLAG_DECODING_PARAM)
    public static let audio = Flag(rawValue: AV_OPT_FLAG_AUDIO_PARAM)
    public static let video = Flag(rawValue: AV_OPT_FLAG_VIDEO_PARAM)
    public static let subtitle = Flag(rawValue: AV_OPT_FLAG_SUBTITLE_PARAM)
    /// The option is intended for exporting values to the caller.
    public static let export = Flag(rawValue: AV_OPT_FLAG_EXPORT)
    /// The option may not be set through the `AVOption` API, only read.
    /// This flag only makes sense when `export` is also set.
    public static let readonly = Flag(rawValue: AV_OPT_FLAG_READONLY)
    /// A generic parameter which can be set by the user for bit stream filtering.
    public static let bsf = Flag(rawValue: AV_OPT_FLAG_BSF_PARAM)
    /// A generic parameter which can be set by the user for filtering.
    public static let filtering = Flag(rawValue: AV_OPT_FLAG_FILTERING_PARAM)
    /// Set if option is deprecated, users should refer to `AVOption.help` text for more information.
    public static let deprecated = Flag(rawValue: AV_OPT_FLAG_DEPRECATED)

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
  }
}

extension AVOption.Flag: CustomStringConvertible {
  public var description: String {
    var str = "["
    if contains(.encoding) { str += "encoding, " }
    if contains(.decoding) { str += "decoding, " }
    if contains(.audio) { str += "audio, " }
    if contains(.video) { str += "video, " }
    if contains(.subtitle) { str += "subtitle, " }
    if contains(.export) { str += "export, " }
    if contains(.bsf) { str += "bsf, " }
    if contains(.filtering) { str += "filtering, " }
    if contains(.deprecated) { str += "deprecated, " }
    if str.suffix(2) == ", " {
      str.removeLast(2)
    }
    str += "]"
    return str
  }
}

// MARK: - AVOptionSearchFlag

extension AVOption {
  // https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/opt.h#L556
  public struct SearchFlag: OptionSet {
    /// Search in possible children of the given object first.
    public static let children = SearchFlag(rawValue: 1 << 0)
    /// The obj passed to `av_opt_find()` is fake – only a double pointer to `AVClass`
    /// instead of a required pointer to a struct containing `AVClass`.
    /// This is useful for searching for options without needing to allocate the corresponding object.
    public static let fakeObject = SearchFlag(rawValue: 1 << 1)
    /// In av_opt_get, return NULL if the option has a pointer type and is set to NULL,
    /// rather than returning an empty string.
    public static let nullable = SearchFlag(rawValue: 1 << 2)

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
  }
}

@available(*, deprecated, renamed: "AVOption.SearchFlag")
public typealias AVOptionSearchFlag = AVOption.SearchFlag

// MARK: - AVOptionSupport

public protocol AVOptionSupport {
  func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T
}

extension AVOptionSupport {
  /// Returns an array of the options supported by the type.
  public var supportedOptions: [AVOption] {
    withUnsafeObjectPointer { ptr in
      var list = [AVOption]()
      var prev: UnsafePointer<CAVOption>?
      while let option = av_opt_next(ptr, prev) {
        list.append(AVOption(cOption: option.pointee))
        prev = option
      }
      return list
    }
  }
}

// MARK: - Option Getter

extension AVOptionSupport {
  /// Returns the string value associated with the specified key.
  ///
  /// - Parameters:
  ///   - key: The name of the option to get.
  ///   - searchFlags: The flags passed to av_opt_find2.
  /// - Returns: The string value associated with the specified key.
  /// - Throws: AVError
  public func string(
    forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws -> String {
    try withUnsafeObjectPointer { ptr in
      var value: UnsafeMutablePointer<UInt8>!
      defer { av_free(value) }
      try throwIfFail(av_opt_get(ptr, key, searchFlags.rawValue, &value))
      return String(cString: value)
    }
  }

  /// Returns the integer value associated with the specified key.
  ///
  /// - Parameters:
  ///   - key: The name of the option to get.
  ///   - searchFlags: The flags passed to av_opt_find2.
  /// - Returns: The integer value associated with the specified key.
  /// - Throws: AVError
  public func integer<T: FixedWidthInteger>(
    forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws -> T {
    try withUnsafeObjectPointer { ptr in
      var value: Int64 = 0
      try throwIfFail(av_opt_get_int(ptr, key, searchFlags.rawValue, &value))
      return T(value)
    }
  }

  /// Returns the double value associated with the specified key.
  ///
  /// - Parameters:
  ///   - key: The name of the option to get.
  ///   - searchFlags: The flags passed to av_opt_find2.
  /// - Returns: The double value associated with the specified key.
  /// - Throws: AVError
  public func double(
    forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws -> Double {
    try withUnsafeObjectPointer { ptr in
      var value: Double = 0
      try throwIfFail(av_opt_get_double(ptr, key, searchFlags.rawValue, &value))
      return value
    }
  }

  /// Returns the rational value associated with the specified key.
  ///
  /// - Parameters:
  ///   - key: The name of the option to get.
  ///   - searchFlags: The flags passed to av_opt_find2.
  /// - Returns: The rational value associated with the specified key.
  /// - Throws: AVError
  public func rational(
    forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws -> AVRational {
    try withUnsafeObjectPointer { ptr in
      var value = AVRational(num: 0, den: 0)
      try throwIfFail(av_opt_get_q(ptr, key, searchFlags.rawValue, &value))
      return value
    }
  }

  /// Returns the image size associated with the specified key.
  ///
  /// - Parameters:
  ///   - key: The name of the option to get.
  ///   - searchFlags: The flags passed to av_opt_find2.
  /// - Returns: The image size associated with the specified key.
  /// - Throws: AVError
  public func size(
    forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws -> (width: Int, height: Int) {
    try withUnsafeObjectPointer { ptr in
      var width: Int32 = 0
      var height: Int32 = 0
      try throwIfFail(av_opt_get_image_size(ptr, key, searchFlags.rawValue, &width, &height))
      return (Int(width), Int(height))
    }
  }

  /// Returns the pixel format associated with the specified key.
  ///
  /// - Parameters:
  ///   - key: The name of the option to get.
  ///   - searchFlags: The flags passed to av_opt_find2.
  /// - Returns: The pixel format associated with the specified key.
  /// - Throws: AVError
  public func pixelFormat(
    forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws -> AVPixelFormat {
    try withUnsafeObjectPointer { ptr in
      var value = AVPixelFormat.none
      try throwIfFail(av_opt_get_pixel_fmt(ptr, key, searchFlags.rawValue, &value))
      return value
    }
  }

  /// Returns the sample format associated with the specified key.
  ///
  /// - Parameters:
  ///   - key: The name of the option to get.
  ///   - searchFlags: The flags passed to av_opt_find2.
  /// - Returns: The sample format associated with the specified key.
  /// - Throws: AVError
  public func sampleFormat(
    forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws -> AVSampleFormat {
    try withUnsafeObjectPointer { ptr in
      var value = AV_SAMPLE_FMT_NONE
      try throwIfFail(av_opt_get_sample_fmt(ptr, key, searchFlags.rawValue, &value))
      return AVSampleFormat(native: value)
    }
  }

  /// Returns the video rate associated with the specified key.
  ///
  /// - Parameters:
  ///   - key: The name of the option to get.
  ///   - searchFlags: The flags passed to av_opt_find2.
  /// - Returns: The video rate associated with the specified key.
  /// - Throws: AVError
  public func videoRate(
    forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws -> AVRational {
    try withUnsafeObjectPointer { ptr in
      var value = AVRational(num: 0, den: 0)
      try throwIfFail(av_opt_get_video_rate(ptr, key, searchFlags.rawValue, &value))
      return value
    }
  }

  /// Returns the channel layout associated with the specified key.
  ///
  /// - Parameters:
  ///   - key: The name of the option to get.
  ///   - searchFlags: The flags passed to av_opt_find2.
  /// - Returns: The channel layout associated with the specified key.
  /// - Throws: AVError
  public func channelLayout(
    forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws -> AVChannelLayout {
    try withUnsafeObjectPointer { ptr in
      var value = AVChannelLayout()
      try throwIfFail(av_opt_get_chlayout(ptr, key, searchFlags.rawValue, &value))
      return value
    }
  }
}

// MARK: - Option Setter

extension AVOptionSupport {
  /// Sets the value of the specified key.
  ///
  /// If the field is not of a string type, then the given string is parsed.
  /// SI postfixes and some named scalars are supported.
  /// If the field is of a numeric type, it has to be a numeric or named
  /// scalar. Behavior with more than one scalar and +- infix operators
  /// is undefined.
  /// If the field is of a flags type, it has to be a sequence of numeric
  /// scalars or named flags separated by '+' or '-'. Prefixing a flag
  /// with '+' causes it to be set without affecting the other flags;
  /// similarly, '-' unsets a flag.
  /// If the field is of a dictionary type, it has to be a ':' separated list of
  /// key=value parameters. Values containing ':' special characters must be
  /// escaped.
  ///
  /// - Parameters:
  ///   - value: The value to set.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func set(
    _ value: String, forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try withUnsafeObjectPointer { ptr in
      try throwIfFail(av_opt_set(ptr, key, value, searchFlags.rawValue))
    }
  }

  /// Sets the value of the specified key to the integer value.
  ///
  /// - Parameters:
  ///   - value: The integer value.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func set<T: FixedWidthInteger>(
    _ value: T, forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try withUnsafeObjectPointer { ptr in
      try throwIfFail(av_opt_set_int(ptr, key, Int64(value), searchFlags.rawValue))
    }
  }

  /// Sets the value of the specified key to the double value.
  ///
  /// - Parameters:
  ///   - value: The double value.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func set(
    _ value: Double, forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try withUnsafeObjectPointer { ptr in
      try throwIfFail(av_opt_set_double(ptr, key, value, searchFlags.rawValue))
    }
  }

  /// Sets the value of the specified key to the rational value.
  ///
  /// - Parameters:
  ///   - value: The rational value.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func set(
    _ value: AVRational, forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try withUnsafeObjectPointer { ptr in
      try throwIfFail(av_opt_set_q(ptr, key, value, searchFlags.rawValue))
    }
  }

  /// Sets the value of the specified key to the binary value.
  ///
  /// - Parameters:
  ///   - value: The binary value.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func set(
    _ value: UnsafeBufferPointer<UInt8>, forKey key: String,
    searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try withUnsafeObjectPointer { ptr in
      try throwIfFail(
        av_opt_set_bin(ptr, key, value.baseAddress, Int32(value.count), searchFlags.rawValue))
    }
  }

  /// Sets the value of the specified key to the image size.
  ///
  /// - Parameters:
  ///   - value: The image size.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func set(
    _ size: (width: Int, height: Int), forKey key: String,
    searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try withUnsafeObjectPointer { ptr in
      try throwIfFail(
        av_opt_set_image_size(
          ptr, key, Int32(size.width), Int32(size.height), searchFlags.rawValue
        )
      )
    }
  }

  /// Sets the value of the specified key to the pixel format.
  ///
  /// - Parameters:
  ///   - value: The pixel format.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func set(
    _ value: AVPixelFormat, forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try withUnsafeObjectPointer { ptr in
      try throwIfFail(av_opt_set_pixel_fmt(ptr, key, value, searchFlags.rawValue))
    }
  }

  /// Sets the value of the specified key to the sample format.
  ///
  /// - Parameters:
  ///   - value: The sample format.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func set(
    _ value: AVSampleFormat, forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try withUnsafeObjectPointer { ptr in
      try throwIfFail(av_opt_set_sample_fmt(ptr, key, value.native, searchFlags.rawValue))
    }
  }

  /// Sets the value of the specified key to the video rate.
  ///
  /// - Parameters:
  ///   - value: The video rate.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func setVideoRate(
    _ value: AVRational, forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try withUnsafeObjectPointer { ptr in
      try throwIfFail(av_opt_set_video_rate(ptr, key, value, searchFlags.rawValue))
    }
  }

  /// Sets the value of the specified key to the channel layout.
  ///
  /// - Parameters:
  ///   - value: The channel layout.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func set(
    _ value: AVChannelLayout, forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try withUnsafeObjectPointer { ptr in
      try withUnsafePointer(to: value) { chl in
        try throwIfFail(av_opt_set_chlayout(ptr, key, chl, searchFlags.rawValue))
      }
    }
  }

  /// Sets the value of the specified key to the integer array.
  ///
  /// - Parameters:
  ///   - value: The integer array.
  ///   - key: The key with which to associate the value.
  ///   - searchFlags: The flags passed to `av_opt_find2`.
  /// - Throws: AVError
  public func set<T: FixedWidthInteger>(
    _ value: [T], forKey key: String, searchFlags: AVOption.SearchFlag = .children
  ) throws {
    try value.withUnsafeBytes { ptr in
      let ptr = ptr.bindMemory(to: UInt8.self).baseAddress
      let count = MemoryLayout<T>.size * value.count
      try set(UnsafeBufferPointer(start: ptr, count: count), forKey: key)
    }
  }
}
