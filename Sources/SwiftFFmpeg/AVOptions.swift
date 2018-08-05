//
//  AVOptions.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/10.
//

import CFFmpeg

// MARK: - AVOptionType

public typealias AVOptionType = CFFmpeg.AVOptionType

extension AVOptionType: CustomStringConvertible {
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
    public static let pixelFmt = AV_OPT_TYPE_PIXEL_FMT
    public static let sampleFmt = AV_OPT_TYPE_SAMPLE_FMT
    /// offset must point to AVRational
    public static let videoRate = AV_OPT_TYPE_VIDEO_RATE
    public static let duration = AV_OPT_TYPE_DURATION
    public static let color = AV_OPT_TYPE_COLOR
    public static let channelLayout = AV_OPT_TYPE_CHANNEL_LAYOUT
    public static let bool = AV_OPT_TYPE_BOOL

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
        case .pixelFmt:
            return "pixel format"
        case .sampleFmt:
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

internal typealias CAVOption = CFFmpeg.AVOption

public struct AVOption: CustomStringConvertible {
    internal let option: CAVOption

    internal init(option: CAVOption) {
        self.option = option
    }

    public var name: String {
        return String(cString: option.name)
    }

    /// short English help text
    public var help: String {
        if let strBytes = option.help {
            return String(cString: strBytes)
        }
        return ""
    }

    public var type: AVOptionType {
        return option.type
    }

    public var defaultValue: Any {
        switch type {
        case .flags, .int, .int64, .uint64, .channelLayout:
            return option.default_val.i64
        case .double, .float:
            return option.default_val.dbl
        case .bool:
            return option.default_val.i64 != 0 ? "true" : "false"
        case .string:
            if let strBytes = option.default_val.str {
                return String(cString: strBytes)
            }
            return ""
        case .rational:
            return String(describing: option.default_val.q)
        default:
            return "unknown"
        }
    }

    public var description: String {
        return """
        \(name):
            desc: \(help)
            type: \(type)
            default: \(defaultValue)
        """
    }
}

// MARK: - AVOptionSearchFlag

public enum AVOptionSearchFlag: Int32 {
    /// Search in possible children of the given object first.
    case children = 1
    /// The obj passed to av_opt_find() is fake – only a double pointer to AVClass
    /// instead of a required pointer to a struct containing AVClass.
    case fakeObj = 2
}

// MARK: - AVOptionProtocol

public protocol AVOptionProtocol {
    var objPtr: UnsafeMutableRawPointer { get }
}

extension AVOptionProtocol {

    /// Set the field of obj with the given name to value.
    ///
    /// av_opt_set
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - key: the name of the field to set
    ///   - searchFlags: flags passed to av_opt_find2.
    /// - Throws: AVError
    public func set(_ value: String, forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws {
        try throwIfFail(av_opt_set(objPtr, key, value, searchFlags.rawValue))
    }

    /// av_opt_set_int
    public func set<T: FixedWidthInteger>(
        _ value: T, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try throwIfFail(av_opt_set_int(objPtr, key, Int64(value), searchFlags.rawValue))
    }

    /// av_opt_set_double
    public func set(_ value: Double, forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws {
        try throwIfFail(av_opt_set_double(objPtr, key, value, searchFlags.rawValue))
    }

    /// av_opt_set_q
    public func set(_ value: AVRational, forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws {
        try throwIfFail(av_opt_set_q(objPtr, key, value, searchFlags.rawValue))
    }

    /// av_opt_set_bin
    public func set(
        _ value: UnsafePointer<UInt8>, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try throwIfFail(av_opt_set_bin(objPtr, key, value, 0, searchFlags.rawValue))
    }

    /// av_opt_set_pixel_fmt
    public func set(_ value: AVPixelFormat, forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws {
        try throwIfFail(av_opt_set_pixel_fmt(objPtr, key, value, searchFlags.rawValue))
    }

    /// av_opt_set_sample_fmt
    public func set(_ value: AVSampleFormat, forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws {
        try throwIfFail(av_opt_set_sample_fmt(objPtr, key, value, searchFlags.rawValue))
    }

    /// av_opt_set_image_size
    public func setImageSize(
        _ size: (width: Int, height: Int), forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try throwIfFail(av_opt_set_image_size(objPtr, key, Int32(size.width), Int32(size.height), searchFlags.rawValue))
    }

    /// av_opt_set_video_rate
    public func setVideoRate(
        _ value: AVRational, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try throwIfFail(av_opt_set_video_rate(objPtr, key, value, searchFlags.rawValue))
    }

    /// av_opt_set_channel_layout
    public func setChannelLayout(
        _ value: AVChannelLayout, forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws {
        try throwIfFail(av_opt_set_channel_layout(objPtr, key, Int64(value.rawValue), searchFlags.rawValue))
    }

    /// Get a value of the option with the given name from an object.
    ///
    /// av_opt_get
    ///
    /// - Parameters:
    ///   - key: name of the option to get.
    ///   - searchFlags: flags passed to av_opt_find2.
    /// - Returns: value of the option
    /// - Throws: AVError
    public func string(forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws -> String {
        var outVal: UnsafeMutablePointer<UInt8>?
        try throwIfFail(av_opt_get(objPtr, key, searchFlags.rawValue, &outVal))
        return String(cString: outVal!)
    }

    /// av_opt_get_int
    public func integer(forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws -> Int64 {
        var outVal: Int64 = 0
        try throwIfFail(av_opt_get_int(objPtr, key, searchFlags.rawValue, &outVal))
        return outVal
    }

    /// av_opt_get_double
    public func double(forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws -> Double {
        var outVal: Double = 0
        try throwIfFail(av_opt_get_double(objPtr, key, searchFlags.rawValue, &outVal))
        return outVal
    }

    /// av_opt_get_q
    public func rational(forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws -> AVRational {
        var outVal = AVRational(num: 0, den: 0)
        try throwIfFail(av_opt_get_q(objPtr, key, searchFlags.rawValue, &outVal))
        return outVal
    }

    /// av_opt_get
    public func binary(
        forKey key: String, searchFlags: AVOptionSearchFlag = .children
    ) throws -> UnsafeMutablePointer<UInt8> {
        var outVal: UnsafeMutablePointer<UInt8>?
        try throwIfFail(av_opt_get(objPtr, key, searchFlags.rawValue, &outVal))
        return outVal!
    }

    /// av_opt_get_image_size
    public func size(forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws -> (Int, Int) {
        var wOutVal: Int32 = 0
        var hOutVal: Int32 = 0
        try throwIfFail(av_opt_get_image_size(objPtr, key, searchFlags.rawValue, &wOutVal, &hOutVal))
        return (Int(wOutVal), Int(hOutVal))
    }

    /// av_opt_get_pixel_fmt
    public func pixelFmt(forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws -> AVPixelFormat {
        var outVal = AVPixelFormat.NONE
        try throwIfFail(av_opt_get_pixel_fmt(objPtr, key, searchFlags.rawValue, &outVal))
        return outVal
    }

    /// av_opt_get_sample_fmt
    public func sampleFmt(forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws -> AVSampleFormat {
        var outVal = AVSampleFormat.NONE
        try throwIfFail(av_opt_get_sample_fmt(objPtr, key, searchFlags.rawValue, &outVal))
        return outVal
    }

    /// av_opt_get_video_rate
    public func videoRate(forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws -> AVRational {
        var outVal = AVRational(num: 0, den: 0)
        try throwIfFail(av_opt_get_video_rate(objPtr, key, searchFlags.rawValue, &outVal))
        return outVal
    }

    /// av_opt_get_channel_layout
    public func channelLayout(forKey key: String, searchFlags: AVOptionSearchFlag = .children) throws -> Int64 {
        var outVal: Int64 = 0
        try throwIfFail(av_opt_get_channel_layout(objPtr, key, searchFlags.rawValue, &outVal))
        return outVal
    }

    public var all: [AVOption] {
        var list = [AVOption]()
        var prev: UnsafePointer<CAVOption>?
        while let option = av_opt_next(objPtr, prev) {
            list.append(AVOption(option: option.pointee))
            prev = option
        }
        return list
    }
}
// MARK: - Extensions

extension AVFormatContext: AVOptionProtocol {

    public var objPtr: UnsafeMutableRawPointer {
        let ptr = UnsafeMutablePointer<UnsafePointer<CAVClass>>.allocate(capacity: 1)
        ptr.initialize(to: avClass.clazzPtr)
        defer { ptr.deallocate() }
        return UnsafeMutableRawPointer(ptr)
    }
}

extension AVCodecContext: AVOptionProtocol {

    public var objPtr: UnsafeMutableRawPointer {
        return ctx.priv_data
    }
}

extension AVCodec: AVOptionProtocol {

    public var objPtr: UnsafeMutableRawPointer {
        let ptr = UnsafeMutablePointer<UnsafePointer<CAVClass>>.allocate(capacity: 1)
        ptr.initialize(to: codec.priv_class)
        defer { ptr.deallocate() }
        return UnsafeMutableRawPointer(ptr)
    }
}

extension SwsContext: AVOptionProtocol {

    public var objPtr: UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(ctx)
    }
}

extension SwrContext: AVOptionProtocol {

    public var objPtr: UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(ctx)
    }
}
