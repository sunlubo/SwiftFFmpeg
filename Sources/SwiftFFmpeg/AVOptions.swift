//
//  AVOptions.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/10.
//

import CFFmpeg

// MARK: - AVOptionType

public typealias AVOptionType = CFFmpeg.AVOptionType

extension AVOptionType {
    public static let flags = AV_OPT_TYPE_FLAGS
    public static let int = AV_OPT_TYPE_INT
    public static let int64 = AV_OPT_TYPE_INT64
    public static let double = AV_OPT_TYPE_DOUBLE
    public static let float = AV_OPT_TYPE_FLOAT
    public static let string = AV_OPT_TYPE_STRING
    public static let rational = AV_OPT_TYPE_RATIONAL
    /// offset must point to a pointer immediately followed by an int for the length
    public static let binary = AV_OPT_TYPE_BINARY
    public static let dict = AV_OPT_TYPE_DICT
    public static let uint64 = AV_OPT_TYPE_UINT64
    public static let const = AV_OPT_TYPE_CONST
    /// offset must point to two consecutive integers
    public static let imageSize = AV_OPT_TYPE_IMAGE_SIZE
    public static let pixelFormat = AV_OPT_TYPE_PIXEL_FMT
    public static let sampleFormat = AV_OPT_TYPE_SAMPLE_FMT
    /// offset must point to `AVRational`
    public static let videoRate = AV_OPT_TYPE_VIDEO_RATE
    public static let duration = AV_OPT_TYPE_DURATION
    public static let color = AV_OPT_TYPE_COLOR
    public static let channelLayout = AV_OPT_TYPE_CHANNEL_LAYOUT
    public static let bool = AV_OPT_TYPE_BOOL
}

extension AVOptionType: CustomStringConvertible {

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
        default:
            return "unknown"
        }
    }
}

// MARK: - AVOption

typealias CAVOption = CFFmpeg.AVOption

public struct AVOption: CustomStringConvertible {
    public let name: String
    /// The short English help text about the option.
    public let help: String?
    /// The offset relative to the context structure where the option value is stored.
    /// It should be 0 for named constants.
    public let offset: Int
    public let type: AVOptionType
    /// The default value for scalar options.
    public let defaultValue: Any
    /// The minimum valid value for the option.
    public let min: Double
    /// The maximum valid value for the option.
    public let max: Double
    public let flags: Flag
    /// The logical unit to which the option belongs.
    /// Non-constant options and corresponding named constants share the same unit.
    public let unit: String?

    init(cOption: CAVOption) {
        self.name = String(cString: cOption.name)
        self.help = String(cString: cOption.help)
        self.offset = Int(cOption.offset)
        self.type = cOption.type
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
        default:
            self.defaultValue = "unknown"
        }
    }

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

// MARK: - AVOption.Flag

extension AVOption {

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

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
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

public enum AVOptionSearchFlag: Int32 {
    /// Search in possible children of the given object first.
    case children = 1
    /// The obj passed to `av_opt_find()` is fake – only a double pointer to `AVClass`
    /// instead of a required pointer to a struct containing `AVClass`.
    /// This is useful for searching for options without needing to allocate the corresponding object.
    case fakeObject = 2
}

// MARK: - AVOptionAccessor

public protocol AVOptionAccessor {
    func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T
}

// MARK: - Option setting functions

extension AVOptionAccessor {

    /// Set the field of obj with the given name to value.
    ///
    /// `av_opt_set`
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - key: The name of the field to set.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    public func set(
        _ value: String, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try withUnsafeObjectPointer { objPtr in
            try throwIfFail(av_opt_set(objPtr, key, value, searchFlags.rawValue))
        }
    }

    /// `av_opt_set_int`
    public func set<T: FixedWidthInteger>(
        _ value: T, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try withUnsafeObjectPointer { objPtr in
            try throwIfFail(av_opt_set_int(objPtr, key, Int64(value), searchFlags.rawValue))
        }
    }

    /// `av_opt_set_double`
    public func set(
        _ value: Double, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try withUnsafeObjectPointer { objPtr in
            try throwIfFail(av_opt_set_double(objPtr, key, value, searchFlags.rawValue))
        }
    }

    /// `av_opt_set_q`
    public func set(
        _ value: AVRational, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try withUnsafeObjectPointer { objPtr in
            try throwIfFail(av_opt_set_q(objPtr, key, value, searchFlags.rawValue))
        }
    }

    /// `av_opt_set_bin`
    public func set(
        _ value: UnsafeBufferPointer<UInt8>, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try withUnsafeObjectPointer { objPtr in
            try throwIfFail(av_opt_set_bin(objPtr, key, value.baseAddress, Int32(value.count), searchFlags.rawValue))
        }
    }

    /// `av_opt_set_image_size`
    public func set(
        _ size: (width: Int, height: Int), forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try withUnsafeObjectPointer { objPtr in
            try throwIfFail(
                av_opt_set_image_size(objPtr, key, Int32(size.width), Int32(size.height), searchFlags.rawValue)
            )
        }
    }

    /// `av_opt_set_pixel_fmt`
    public func set(
        _ value: AVPixelFormat, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try withUnsafeObjectPointer { objPtr in
            try throwIfFail(av_opt_set_pixel_fmt(objPtr, key, value, searchFlags.rawValue))
        }
    }

    /// `av_opt_set_sample_fmt`
    public func set(
        _ value: AVSampleFormat, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try withUnsafeObjectPointer { objPtr in
            try throwIfFail(av_opt_set_sample_fmt(objPtr, key, value, searchFlags.rawValue))
        }
    }

    /// `av_opt_set_video_rate`
    public func setVideoRate(
        _ value: AVRational, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try withUnsafeObjectPointer { objPtr in
            try throwIfFail(av_opt_set_video_rate(objPtr, key, value, searchFlags.rawValue))
        }
    }

    /// `av_opt_set_channel_layout`
    public func set(
        _ value: AVChannelLayout, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try withUnsafeObjectPointer { objPtr in
            try throwIfFail(av_opt_set_channel_layout(objPtr, key, Int64(value.rawValue), searchFlags.rawValue))
        }
    }

    /// Set a binary option to an integer list.
    ///
    /// `av_opt_set_int_list`
    public func set<T: FixedWidthInteger>(
        _ value: [T], forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        precondition(value.last == 0 || value.last == -1, "The list must be terminated by 0 or -1.")
        try value.withUnsafeBytes { ptr in
            let ptr = ptr.bindMemory(to: UInt8.self).baseAddress
            let count = MemoryLayout<T>.size * (value.count - 1)
            try set(UnsafeBufferPointer(start: ptr, count: count), forKey: key)
        }
    }
}

// MARK: - Option getting functions

extension AVOptionAccessor {

    /// Get a value of the option with the given name from an object.
    ///
    /// `av_opt_get`
    ///
    /// - Parameters:
    ///   - key: The name of the option to get.
    ///   - searchFlags: The flags passed to av_opt_find2.
    /// - Returns: value of the option
    /// - Throws: AVError
    public func string(
        forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws -> String {
        return try withUnsafeObjectPointer { objPtr in
            var outVal: UnsafeMutablePointer<UInt8>?
            try throwIfFail(av_opt_get(objPtr, key, searchFlags.rawValue, &outVal))
            return String(cString: outVal!)
        }
    }

    /// `av_opt_get_int`
    public func integer<T: FixedWidthInteger>(
        forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws -> T {
        return try withUnsafeObjectPointer { objPtr in
            var outVal: Int64 = 0
            try throwIfFail(av_opt_get_int(objPtr, key, searchFlags.rawValue, &outVal))
            return T(outVal)
        }
    }

    /// `av_opt_get_double`
    public func double(
        forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws -> Double {
        return try withUnsafeObjectPointer { objPtr in
            var outVal: Double = 0
            try throwIfFail(av_opt_get_double(objPtr, key, searchFlags.rawValue, &outVal))
            return outVal
        }
    }

    /// `av_opt_get_q`
    public func rational(
        forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws -> AVRational {
        return try withUnsafeObjectPointer { objPtr in
            var outVal = AVRational(num: 0, den: 0)
            try throwIfFail(av_opt_get_q(objPtr, key, searchFlags.rawValue, &outVal))
            return outVal
        }
    }

    /// `av_opt_get_image_size`
    public func size(
        forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws -> (Int, Int) {
        return try withUnsafeObjectPointer { objPtr in
            var wOutVal: Int32 = 0
            var hOutVal: Int32 = 0
            try throwIfFail(av_opt_get_image_size(objPtr, key, searchFlags.rawValue, &wOutVal, &hOutVal))
            return (Int(wOutVal), Int(hOutVal))
        }
    }

    /// `av_opt_get_pixel_fmt`
    public func pixelFormat(
        forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws -> AVPixelFormat {
        return try withUnsafeObjectPointer { objPtr in
            var outVal = AVPixelFormat.none
            try throwIfFail(av_opt_get_pixel_fmt(objPtr, key, searchFlags.rawValue, &outVal))
            return outVal
        }
    }

    /// `av_opt_get_sample_fmt`
    public func sampleFormat(
        forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws -> AVSampleFormat {
        return try withUnsafeObjectPointer { objPtr in
            var outVal = AVSampleFormat.none
            try throwIfFail(av_opt_get_sample_fmt(objPtr, key, searchFlags.rawValue, &outVal))
            return outVal
        }
    }

    /// `av_opt_get_video_rate`
    public func videoRate(
        forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws -> AVRational {
        return try withUnsafeObjectPointer { objPtr in
            var outVal = AVRational(num: 0, den: 0)
            try throwIfFail(av_opt_get_video_rate(objPtr, key, searchFlags.rawValue, &outVal))
            return outVal
        }
    }

    /// `av_opt_get_channel_layout`
    public func channelLayout(
        forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws -> Int64 {
        return try withUnsafeObjectPointer { objPtr in
            var outVal: Int64 = 0
            try throwIfFail(av_opt_get_channel_layout(objPtr, key, searchFlags.rawValue, &outVal))
            return outVal
        }
    }

    /// Returns an array of the options supported by the type.
    public var supportedOptions: [AVOption] {
        return withUnsafeObjectPointer { objPtr in
            var list = [AVOption]()
            var prev: UnsafePointer<CAVOption>?
            while let option = av_opt_next(objPtr, prev) {
                list.append(AVOption(cOption: option.pointee))
                prev = option
            }
            return list
        }
    }
}
