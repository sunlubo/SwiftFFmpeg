//
//  AudioUtil.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/2.
//

import CFFmpeg

// MARK: - AVSampleFormat

public typealias AVSampleFormat = CFFmpeg.AVSampleFormat

extension AVSampleFormat {
    public static let NONE = AV_SAMPLE_FMT_NONE
    /// unsigned 8 bits
    public static let U8 = AV_SAMPLE_FMT_U8
    /// signed 16 bits
    public static let S16 = AV_SAMPLE_FMT_S16
    /// signed 32 bits
    public static let S32 = AV_SAMPLE_FMT_S32
    /// float
    public static let FLT = AV_SAMPLE_FMT_FLT
    /// double
    public static let DBL = AV_SAMPLE_FMT_DBL
    /// unsigned 8 bits, planar
    public static let U8P = AV_SAMPLE_FMT_U8P
    /// signed 16 bits, planar
    public static let S16P = AV_SAMPLE_FMT_S16P
    /// signed 32 bits, planar
    public static let S32P = AV_SAMPLE_FMT_S32P
    /// float, planar
    public static let FLTP = AV_SAMPLE_FMT_FLTP
    /// double, planar
    public static let DBLP = AV_SAMPLE_FMT_DBLP
    /// signed 64 bits
    public static let S64 = AV_SAMPLE_FMT_S64
    /// signed 64 bits, planar
    public static let S64P = AV_SAMPLE_FMT_S64P
    /// Number of sample formats. **DO NOT USE** if linking dynamically.
    public static let NB = AV_SAMPLE_FMT_NB

    /// The name of the sample format, or nil if sample format is not recognized.
    public var name: String {
        return String(cString: av_get_sample_fmt_name(self)) ?? "unknown"
    }

    /// Number of bytes per sample or zero if unknown for the given sample format.
    public var bytesPerSample: Int {
        return Int(av_get_bytes_per_sample(self))
    }

    /// A Boolean value indicating whether the sample format is planar.
    public var isPlanar: Bool {
        return av_sample_fmt_is_planar(self) == 1
    }

    /// A Boolean value indicating whether the sample format is packed.
    public var isPacked: Bool {
        return !isPlanar
    }

    /// Return the planar alternative form of the given sample format or `AVSampleFormat.NONE` on error.
    ///
    /// If the passed sample format is already in planar format, the format returned is the same as the input.
    public func toPlanar() -> AVSampleFormat {
        return av_get_planar_sample_fmt(self)
    }

    /// Return the packed alternative form of the given sample format or `AVSampleFormat.NONE` on error.
    ///
    /// If the passed sample format is already in packed format, the format returned is the same as the input.
    public func toPacked() -> AVSampleFormat {
        return av_get_packed_sample_fmt(self)
    }
}

extension AVSampleFormat: CustomStringConvertible {

    public var description: String {
        return name
    }
}

// MARK: - Audio Channel

// A channel layout is a 64-bits integer with a bit set for every channel.
// The number of bits set must be equal to the number of channels.
// The value 0 means that the channel layout is not known.
// @note this data structure is not powerful enough to handle channels
// combinations that have the same channel multiple times, such as dual-mono.

public struct AVChannel: Equatable {
    public static let frontLeft = AVChannel(rawValue: UInt64(AV_CH_FRONT_LEFT))
    public static let frontRight = AVChannel(rawValue: UInt64(AV_CH_FRONT_RIGHT))
    public static let frontCenter = AVChannel(rawValue: UInt64(AV_CH_FRONT_CENTER))
    public static let lowFrequency = AVChannel(rawValue: UInt64(AV_CH_LOW_FREQUENCY))
    public static let backLeft = AVChannel(rawValue: UInt64(AV_CH_BACK_LEFT))
    public static let backRight = AVChannel(rawValue: UInt64(AV_CH_BACK_RIGHT))
    public static let frontLeftOfCenter = AVChannel(rawValue: UInt64(AV_CH_FRONT_LEFT_OF_CENTER))
    public static let frontRightOfCenter = AVChannel(rawValue: UInt64(AV_CH_FRONT_RIGHT_OF_CENTER))
    public static let backCenter = AVChannel(rawValue: UInt64(AV_CH_BACK_CENTER))
    public static let sideLeft = AVChannel(rawValue: UInt64(AV_CH_SIDE_LEFT))
    public static let sideRight = AVChannel(rawValue: UInt64(AV_CH_SIDE_RIGHT))
    public static let topCenter = AVChannel(rawValue: UInt64(AV_CH_TOP_CENTER))
    public static let topFrontLeft = AVChannel(rawValue: UInt64(AV_CH_TOP_FRONT_LEFT))
    public static let topFrontCenter = AVChannel(rawValue: UInt64(AV_CH_TOP_FRONT_CENTER))
    public static let topFrontRight = AVChannel(rawValue: UInt64(AV_CH_TOP_FRONT_RIGHT))
    public static let topBackLeft = AVChannel(rawValue: UInt64(AV_CH_TOP_BACK_LEFT))
    public static let topBackCenter = AVChannel(rawValue: UInt64(AV_CH_TOP_BACK_CENTER))
    public static let topBackRight = AVChannel(rawValue: UInt64(AV_CH_TOP_BACK_RIGHT))
    /// Stereo downmix.
    public static let stereoLeft = AVChannel(rawValue: UInt64(AV_CH_STEREO_LEFT))
    /// See AV_CH_STEREO_LEFT.
    public static let stereoRight = AVChannel(rawValue: UInt64(AV_CH_STEREO_RIGHT))
    public static let wideLeft = AVChannel(rawValue: AV_CH_WIDE_LEFT)
    public static let wideRight = AVChannel(rawValue: AV_CH_WIDE_RIGHT)
    public static let surroundDirectLeft = AVChannel(rawValue: AV_CH_SURROUND_DIRECT_LEFT)
    public static let surroundDirectRight = AVChannel(rawValue: AV_CH_SURROUND_DIRECT_RIGHT)
    public static let lowFrequency2 = AVChannel(rawValue: AV_CH_LOW_FREQUENCY_2)

    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    public var name: String {
        return String(cString: av_get_channel_name(rawValue))
    }
}

extension AVChannel: CustomStringConvertible {

    public var description: String {
        return name
    }
}

// MARK: - Audio Channel Layout

public struct AVChannelLayout: Equatable {
    public static let CHL_NONE = AVChannelLayout(rawValue: 0)
    /// Channel mask value used for AVCodecContext.request_channel_layout
    /// to indicate that the user requests the channel order of the decoder output
    /// to be the native codec channel order.
    public static let CHL_NATIVE = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_NATIVE)
    public static let CHL_MONO = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_MONO)
    public static let CHL_STEREO = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_STEREO)
    public static let CHL_2POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_2POINT1)
    public static let CHL_2_1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_2_1)
    public static let CHL_SURROUND = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_SURROUND)
    public static let CHL_3POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_3POINT1)
    public static let CHL_4POINT0 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_4POINT0)
    public static let CHL_4POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_4POINT1)
    public static let CHL_2_2 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_2_2)
    public static let CHL_QUAD = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_QUAD)
    public static let CHL_5POINT0 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_5POINT0)
    public static let CHL_5POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_5POINT1)
    public static let CHL_5POINT0_BACK = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_5POINT0_BACK)
    public static let CHL_5POINT1_BACK = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_5POINT1_BACK)
    public static let CHL_6POINT0 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_6POINT0)
    public static let CHL_6POINT0_FRONT = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_6POINT0_FRONT)
    public static let CHL_HEXAGONAL = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_HEXAGONAL)
    public static let CHL_6POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_6POINT1)
    public static let CHL_6POINT1_BACK = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_6POINT1_BACK)
    public static let CHL_6POINT1_FRONT = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_6POINT1_FRONT)
    public static let CHL_7POINT0 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_7POINT0)
    public static let CHL_7POINT0_FRONT = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_7POINT0_FRONT)
    public static let CHL_7POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_7POINT1)
    public static let CHL_7POINT1_WIDE = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_7POINT1_WIDE)
    public static let CHL_7POINT1_WIDE_BACK = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_7POINT1_WIDE_BACK)
    public static let CHL_OCTAGONAL = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_OCTAGONAL)
    public static let CHL_HEXADECAGONAL = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_HEXADECAGONAL)
    public static let CHL_STEREO_DOWNMIX = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_STEREO_DOWNMIX)

    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    /// Return a channel layout id that matches name, or 0 if no match is found.
    ///
    /// - Parameter name: Name can be one or several of the following notations, separated by '+' or '|':
    ///   - the name of an usual channel layout (mono, stereo, 4.0, quad, 5.0, 5.0(side), 5.1, 5.1(side), 7.1,
    ///     7.1(wide), downmix);
    ///   - the name of a single channel (FL, FR, FC, LFE, BL, BR, FLC, FRC, BC, SL, SR, TC, TFL, TFC, TFR, TBL,
    ///     TBC, TBR, DL, DR);
    ///   - a number of channels, in decimal, followed by 'c', yielding the default channel layout for that number
    ////    of channels (@see av_get_default_channel_layout);
    ///   - a channel layout mask, in hexadecimal starting with "0x" (see the AV_CH_* macros).
    ///
    ///     Example: "stereo+FC" = "2c+FC" = "2c+1c" = "0x7"
    public init(name: String) {
        self.init(rawValue: av_get_channel_layout(name))
    }

    /// Return the number of channels in the channel layout.
    public var channelCount: Int {
        return Int(av_get_channel_layout_nb_channels(rawValue))
    }

    /// Get the index of a channel in channel_layout.
    ///
    /// - Parameter channel: a channel layout describing exactly one channel which must be present in channel_layout.
    /// - Returns: index of channel in channel_layout on success, nil on error.
    public func index(for channel: AVChannel) -> Int? {
        let i = av_get_channel_layout_channel_index(rawValue, channel.rawValue)
        return i >= 0 ? Int(i) : nil
    }

    /// Get default channel layout for a given number of channels.
    ///
    /// - Parameter count: number of channels
    /// - Returns: AVChannelLayout
    public static func `default`(forChannelCount count: Int32) -> AVChannelLayout {
        return AVChannelLayout(rawValue: UInt64(av_get_default_channel_layout(count)))
    }
}

extension AVChannelLayout: CustomStringConvertible {

    public var description: String {
        let buf = UnsafeMutablePointer<Int8>.allocate(capacity: 256)
        buf.initialize(to: 0)
        defer { buf.deallocate() }
        av_get_channel_layout_string(buf, 256, Int32(channelCount), rawValue)
        return String(cString: buf)
    }
}
