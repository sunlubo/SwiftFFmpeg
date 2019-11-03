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
    public static let none = AV_SAMPLE_FMT_NONE
    /// unsigned 8 bits
    public static let u8 = AV_SAMPLE_FMT_U8
    /// signed 16 bits
    public static let s16 = AV_SAMPLE_FMT_S16
    /// signed 32 bits
    public static let s32 = AV_SAMPLE_FMT_S32
    /// float
    public static let flt = AV_SAMPLE_FMT_FLT
    /// double
    public static let dbl = AV_SAMPLE_FMT_DBL
    /// unsigned 8 bits, planar
    public static let u8p = AV_SAMPLE_FMT_U8P
    /// signed 16 bits, planar
    public static let s16p = AV_SAMPLE_FMT_S16P
    /// signed 32 bits, planar
    public static let s32p = AV_SAMPLE_FMT_S32P
    /// float, planar
    public static let fltp = AV_SAMPLE_FMT_FLTP
    /// double, planar
    public static let dblp = AV_SAMPLE_FMT_DBLP
    /// signed 64 bits
    public static let s64 = AV_SAMPLE_FMT_S64
    /// signed 64 bits, planar
    public static let s64p = AV_SAMPLE_FMT_S64P
    /// Number of sample formats. __DO NOT USE__ if linking dynamically.
    public static let nb = AV_SAMPLE_FMT_NB

    /// Return a sample format corresponding to name, or `nil` if the sample format does not exist.
    ///
    /// - Parameter name: The name of the sample format.
    public init?(name: String) {
        let fmt = av_get_sample_fmt(name)
        if fmt == .none { return nil }
        self = fmt
    }

    /// The name of the sample format, or `nil` if sample format is not recognized.
    public var name: String? {
        String(cString: av_get_sample_fmt_name(self))
    }

    /// The number of bytes per sample or zero if unknown for the given sample format.
    public var bytesPerSample: Int {
        Int(av_get_bytes_per_sample(self))
    }

    /// A Boolean value indicating whether the sample format is planar.
    public var isPlanar: Bool {
        av_sample_fmt_is_planar(self) == 1
    }

    /// A Boolean value indicating whether the sample format is packed.
    public var isPacked: Bool {
        !isPlanar
    }

    /// Return the planar alternative form of the given sample format, or `nil` if the planar sample format does not exist.
    ///
    /// If the passed sample format is already in planar format, the format returned is the same as the input.
    public func toPlanar() -> AVSampleFormat? {
        let fmt = av_get_planar_sample_fmt(self)
        if fmt == .none { return nil }
        return fmt
    }

    /// Return the packed alternative form of the given sample format, or `nil` if the packed sample format does not exist.
    ///
    /// If the passed sample format is already in packed format, the format returned is the same as the input.
    public func toPacked() -> AVSampleFormat? {
        let fmt = av_get_packed_sample_fmt(self)
        if fmt == .none { return nil }
        return fmt
    }
}

extension AVSampleFormat: CustomStringConvertible {

    public var description: String {
        name ?? "unknown"
    }
}

// MARK: - Audio Channel

// A channel layout is a 64-bits integer with a bit set for every channel.
// The number of bits set must be equal to the number of channels.
// The value 0 means that the channel layout is not known.
//
// - Note: this data structure is not powerful enough to handle channels
// combinations that have the same channel multiple times, such as dual-mono.

public struct AVChannel: Equatable {
    /// FL
    public static let frontLeft = AVChannel(rawValue: UInt64(AV_CH_FRONT_LEFT))
    /// FR
    public static let frontRight = AVChannel(rawValue: UInt64(AV_CH_FRONT_RIGHT))
    /// FC
    public static let frontCenter = AVChannel(rawValue: UInt64(AV_CH_FRONT_CENTER))
    /// LFE
    public static let lowFrequency = AVChannel(rawValue: UInt64(AV_CH_LOW_FREQUENCY))
    /// BL
    public static let backLeft = AVChannel(rawValue: UInt64(AV_CH_BACK_LEFT))
    /// BR
    public static let backRight = AVChannel(rawValue: UInt64(AV_CH_BACK_RIGHT))
    /// FLC
    public static let frontLeftOfCenter = AVChannel(rawValue: UInt64(AV_CH_FRONT_LEFT_OF_CENTER))
    /// FRC
    public static let frontRightOfCenter = AVChannel(rawValue: UInt64(AV_CH_FRONT_RIGHT_OF_CENTER))
    /// BC
    public static let backCenter = AVChannel(rawValue: UInt64(AV_CH_BACK_CENTER))
    /// SL
    public static let sideLeft = AVChannel(rawValue: UInt64(AV_CH_SIDE_LEFT))
    /// SR
    public static let sideRight = AVChannel(rawValue: UInt64(AV_CH_SIDE_RIGHT))
    /// TC
    public static let topCenter = AVChannel(rawValue: UInt64(AV_CH_TOP_CENTER))
    /// TFL
    public static let topFrontLeft = AVChannel(rawValue: UInt64(AV_CH_TOP_FRONT_LEFT))
    /// TFC
    public static let topFrontCenter = AVChannel(rawValue: UInt64(AV_CH_TOP_FRONT_CENTER))
    /// TFR
    public static let topFrontRight = AVChannel(rawValue: UInt64(AV_CH_TOP_FRONT_RIGHT))
    /// TBL
    public static let topBackLeft = AVChannel(rawValue: UInt64(AV_CH_TOP_BACK_LEFT))
    /// TBC
    public static let topBackCenter = AVChannel(rawValue: UInt64(AV_CH_TOP_BACK_CENTER))
    /// TBR
    public static let topBackRight = AVChannel(rawValue: UInt64(AV_CH_TOP_BACK_RIGHT))
    /// DL
    ///
    /// Stereo downmix.
    public static let stereoLeft = AVChannel(rawValue: UInt64(AV_CH_STEREO_LEFT))
    /// DR
    ///
    /// See `stereoLeft`.
    public static let stereoRight = AVChannel(rawValue: UInt64(AV_CH_STEREO_RIGHT))
    /// WL
    public static let wideLeft = AVChannel(rawValue: AV_CH_WIDE_LEFT)
    /// WR
    public static let wideRight = AVChannel(rawValue: AV_CH_WIDE_RIGHT)
    /// SDL
    public static let surroundDirectLeft = AVChannel(rawValue: AV_CH_SURROUND_DIRECT_LEFT)
    /// SDR
    public static let surroundDirectRight = AVChannel(rawValue: AV_CH_SURROUND_DIRECT_RIGHT)
    /// LFE2
    public static let lowFrequency2 = AVChannel(rawValue: AV_CH_LOW_FREQUENCY_2)

    public let rawValue: UInt64

    public init(rawValue: UInt64) { self.rawValue = rawValue }

    /// The name of the audio channel.
    public var name: String {
        String(cString: av_get_channel_name(rawValue))
    }
}

extension AVChannel: CustomStringConvertible {

    public var description: String {
        name
    }
}

// MARK: - Audio Channel Layout

public struct AVChannelLayout: Equatable {
    public static let none = AVChannelLayout(rawValue: 0)
    /// Channel mask value used for `AVCodecContext.request_channel_layout` to indicate that
    /// the user requests the channel order of the decoder output to be the native codec channel order.
    public static let CHL_NATIVE = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_NATIVE)
    /// FC
    public static let CHL_MONO = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_MONO)
    /// FL+FR
    public static let CHL_STEREO = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_STEREO)
    /// FL+FR+LFE
    public static let CHL_2POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_2POINT1)
    /// FL+FR+BC
    public static let CHL_2_1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_2_1)
    /// FL+FR+FC
    public static let CHL_SURROUND = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_SURROUND)
    /// FL+FR+FC+LFE
    public static let CHL_3POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_3POINT1)
    /// FL+FR+FC+BC
    public static let CHL_4POINT0 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_4POINT0)
    /// FL+FR+FC+BC+LFE
    public static let CHL_4POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_4POINT1)
    /// FL+FR+SL+SR
    public static let CHL_2_2 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_2_2)
    /// FL+FR+BL+BR
    public static let CHL_QUAD = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_QUAD)
    /// FL+FR+FC+SL+SR
    public static let CHL_5POINT0 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_5POINT0)
    /// FL+FR+FC+SL+SR+LFE
    public static let CHL_5POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_5POINT1)
    /// FL+FR+FC+BL+BR
    public static let CHL_5POINT0_BACK = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_5POINT0_BACK)
    /// FL+FR+FC+BL+BR+LFE
    public static let CHL_5POINT1_BACK = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_5POINT1_BACK)
    /// FL+FR+SL+SR+FLC+FRC
    public static let CHL_6POINT0 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_6POINT0)
    /// FL+FR+FLC+FRC+SL+SR
    public static let CHL_6POINT0_FRONT = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_6POINT0_FRONT)
    /// FL+FR+FC+BL+BR+BC
    public static let CHL_HEXAGONAL = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_HEXAGONAL)
    /// FL+FR+FC+SL+SR+LFE+BC
    public static let CHL_6POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_6POINT1)
    /// FL+FR+FC+BL+BR+LFE+BC
    public static let CHL_6POINT1_BACK = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_6POINT1_BACK)
    /// FL+FR+FLC+FRC+SL+SR+LFE
    public static let CHL_6POINT1_FRONT = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_6POINT1_FRONT)
    /// FL+FR+FC+SL+SR+BL+BR
    public static let CHL_7POINT0 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_7POINT0)
    /// FL+FR+FC+SL+SR+FLC+FRC
    public static let CHL_7POINT0_FRONT = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_7POINT0_FRONT)
    /// FL+FR+FC+SL+SR+LFE+BL+BR
    public static let CHL_7POINT1 = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_7POINT1)
    /// FL+FR+FC+SL+SR+LFE+FLC+FRC
    public static let CHL_7POINT1_WIDE = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_7POINT1_WIDE)
    /// FL+FR+FC+BL+BR+LFE+FLC+FRC
    public static let CHL_7POINT1_WIDE_BACK = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_7POINT1_WIDE_BACK)
    /// FL+FR+FC+SL+SR+BL+BC+BR
    public static let CHL_OCTAGONAL = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_OCTAGONAL)
    /// FL+FR+FC+SL+SR+BL+BC+BR+WL+WR+TBL+TBR+TBC+TFC+TFL+TFR
    public static let CHL_HEXADECAGONAL = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_HEXADECAGONAL)
    /// DL+DR
    public static let CHL_STEREO_DOWNMIX = AVChannelLayout(rawValue: swift_AV_CH_LAYOUT_STEREO_DOWNMIX)

    public let rawValue: UInt64

    public init(rawValue: UInt64) { self.rawValue = rawValue }

    /// Return a channel layout id that matches name, or `nil` if no match is found.
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
    public init?(name: String) {
        let layout = av_get_channel_layout(name)
        if layout == .none { return nil }
        self.init(rawValue: layout)
    }

    /// The number of channels in the channel layout.
    public var channelCount: Int {
        Int(av_get_channel_layout_nb_channels(rawValue))
    }

    /// Get the index of a channel in channel layout.
    ///
    /// - Parameter channel: A channel layout describing exactly one channel which must be present in channel layout.
    /// - Returns: The index of channel in channel layout, `nil` on error.
    public func index(for channel: AVChannel) -> Int? {
        let i = av_get_channel_layout_channel_index(rawValue, channel.rawValue)
        return i >= 0 ? Int(i) : nil
    }

    public func channel(at index: Int32) -> AVChannel {
        AVChannel(rawValue: av_channel_layout_extract_channel(rawValue, index))
    }

    /// Get the default channel layout for a given number of channels.
    ///
    /// - Parameter count: The number of channels.
    /// - Returns: AVChannelLayout
    public static func `default`(for count: Int) -> AVChannelLayout {
        AVChannelLayout(rawValue: UInt64(av_get_default_channel_layout(Int32(count))))
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
