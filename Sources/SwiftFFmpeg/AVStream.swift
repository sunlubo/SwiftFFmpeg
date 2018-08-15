//
//  AVStream.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVDiscard

public typealias AVDiscard = CFFmpeg.AVDiscard

extension AVDiscard {
    /// discard nothing
    public static let none = AVDISCARD_NONE
    /// discard useless packets like 0 size packets in avi
    public static let `default` = AVDISCARD_DEFAULT
    /// discard all non reference
    public static let nonRef = AVDISCARD_NONREF
    /// discard all bidirectional frames
    public static let bidir = AVDISCARD_BIDIR
    /// discard all non intra frames
    public static let nonIntra = AVDISCARD_NONINTRA
    /// discard all frames except keyframes
    public static let nonKey = AVDISCARD_NONKEY
    /// discard all
    public static let all = AVDISCARD_ALL
}

// MARK: - Audio

internal typealias CAVCodecParameters = CFFmpeg.AVCodecParameters

/// This class describes the properties of an encoded stream.
public final class AVCodecParameters {
    internal let parametersPtr: UnsafeMutablePointer<CAVCodecParameters>
    internal var parameters: CAVCodecParameters { return parametersPtr.pointee }

    internal init(parametersPtr: UnsafeMutablePointer<CAVCodecParameters>) {
        self.parametersPtr = parametersPtr
    }

    /// General type of the encoded data.
    public var mediaType: AVMediaType {
        return parameters.codec_type
    }

    /// Specific type of the encoded data (the codec used).
    public var codecId: AVCodecID {
        return parameters.codec_id
    }

    /// Additional information about the codec (corresponds to the AVI FOURCC).
    public var codecTag: UInt32 {
        get { return parameters.codec_tag }
        set { parametersPtr.pointee.codec_tag = newValue }
    }

    /// The average bitrate of the encoded data (in bits per second).
    public var bitRate: Int {
        return Int(parameters.bit_rate)
    }
}

// MARK: - Video

extension AVCodecParameters {

    /// Pixel format.
    public var pixFmt: AVPixelFormat {
        return AVPixelFormat(parameters.format)
    }

    /// The width of the video frame in pixels.
    public var width: Int {
        return Int(parameters.width)
    }

    /// The height of the video frame in pixels.
    public var height: Int {
        return Int(parameters.height)
    }

    /// The aspect ratio (width / height) which a single pixel should have when displayed.
    ///
    /// When the aspect ratio is unknown / undefined, the numerator should be
    /// set to 0 (the denominator may have any value).
    public var sampleAspectRatio: AVRational {
        return parameters.sample_aspect_ratio
    }

    /// Number of delayed frames.
    public var videoDelay: Int {
        return Int(parameters.video_delay)
    }
}

// MARK: - Audio

extension AVCodecParameters {

    /// Sample format.
    public var sampleFmt: AVSampleFormat {
        return AVSampleFormat(parameters.format)
    }

    /// The channel layout bitmask. May be 0 if the channel layout is
    /// unknown or unspecified, otherwise the number of bits set must be equal to
    /// the channels field.
    public var channelLayout: AVChannelLayout {
        return AVChannelLayout(rawValue: parameters.channel_layout)
    }

    /// The number of audio channels.
    public var channelCount: Int {
        return Int(parameters.channels)
    }

    /// The number of audio samples per second.
    public var sampleRate: Int {
        return Int(parameters.sample_rate)
    }

    /// Audio frame size, if known. Required by some formats to be static.
    public var frameSize: Int {
        return Int(parameters.frame_size)
    }
}

// MARK: - AVStream

internal typealias CAVStream = CFFmpeg.AVStream

/// Stream structure.
public final class AVStream {
    internal let streamPtr: UnsafeMutablePointer<CAVStream>
    internal var stream: CAVStream { return streamPtr.pointee }

    internal init(streamPtr: UnsafeMutablePointer<CAVStream>) {
        self.streamPtr = streamPtr
    }

    /// Format-specific stream ID.
    ///
    /// - decoding: set by libavformat
    /// - encoding: set by the user, replaced by libavformat if left unset
    public var id: Int32 {
        get { return stream.id }
        set { streamPtr.pointee.id = newValue }
    }

    /// Stream index in `AVFormatContext`.
    public var index: Int {
        return Int(stream.index)
    }

    /// This is the fundamental unit of time (in seconds) in terms of which frame timestamps are represented.
    ///
    /// - decoding: set by libavformat
    /// - encoding: May be set by the caller before avformat_write_header() to provide a hint to the muxer about
    ///   the desired timebase. In avformat_write_header(), the muxer will overwrite this field with the timebase
    ///   that will actually be used for the timestamps written into the file (which may or may not be related to
    ///   the user-provided one, depending on the format).
    public var timebase: AVRational {
        get { return stream.time_base }
        set { streamPtr.pointee.time_base = newValue }
    }

    /// pts of the first frame of the stream in presentation order, in stream time base.
    public var startTime: Int64 {
        return stream.start_time
    }

    public var duration: Int64 {
        return stream.duration
    }

    /// Number of frames in this stream if known or 0.
    public var frameCount: Int {
        return Int(stream.nb_frames)
    }

    /// Selects which packets can be discarded at will and do not need to be demuxed.
    public var discard: AVDiscard {
        get { return stream.discard }
        set { streamPtr.pointee.discard = newValue }
    }

    /// sample aspect ratio (0 if unknown)
    public var sampleAspectRatio: AVRational {
        return stream.sample_aspect_ratio
    }

    public var metadata: [String: String] {
        var dict = [String: String]()
        var tag: UnsafeMutablePointer<AVDictionaryEntry>?
        while let next = av_dict_get(stream.metadata, "", tag, AV_DICT_IGNORE_SUFFIX) {
            dict[String(cString: next.pointee.key)] = String(cString: next.pointee.value)
            tag = next
        }
        return dict
    }

    /// Average framerate.
    ///
    /// - demuxing: May be set by libavformat when creating the stream or in avformat_find_stream_info().
    /// - muxing: May be set by the caller before avformat_write_header().
    public var averageFramerate: AVRational {
        return stream.avg_frame_rate
    }

    /// Real base framerate of the stream.
    /// This is the lowest framerate with which all timestamps can be represented accurately
    /// (it is the least common multiple of all framerates in the stream). Note, this value is just a guess!
    /// For example, if the time base is 1/90000 and all frames have either approximately 3600 or 1800 timer ticks,
    /// then realFramerate will be 50/1.
    public var realFramerate: AVRational {
        return stream.r_frame_rate
    }

    /// Codec parameters associated with this stream.
    public var codecpar: AVCodecParameters {
        return AVCodecParameters(parametersPtr: stream.codecpar)
    }

    public var mediaType: AVMediaType {
        return codecpar.mediaType
    }

    /// Copy the contents of src to dst.
    ///
    /// - Parameter codecpar: AVCodecParameters
    /// - Throws: AVError
    public func setParameters(_ codecpar: AVCodecParameters) throws {
        try throwIfFail(avcodec_parameters_copy(stream.codecpar, codecpar.parametersPtr))
    }

    /// Fill the parameters struct based on the values from the supplied codec context.
    ///
    /// - Parameter codecCtx: AVCodecContext
    /// - Throws: AVError
    public func copyParameters(from codecCtx: AVCodecContext) throws {
        try throwIfFail(avcodec_parameters_from_context(stream.codecpar, codecCtx.ctxPtr))
    }
}
