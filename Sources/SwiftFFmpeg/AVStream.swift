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

// MARK: - AVCodecParameters

typealias CAVCodecParameters = CFFmpeg.AVCodecParameters

/// This class describes the properties of an encoded stream.
public final class AVCodecParameters {
    let cParametersPtr: UnsafeMutablePointer<CAVCodecParameters>
    var cParameters: CAVCodecParameters { return cParametersPtr.pointee }

    private var freeWhenDone: Bool = false

    init(cParametersPtr: UnsafeMutablePointer<CAVCodecParameters>) {
        self.cParametersPtr = cParametersPtr
    }

    /// Create a new `AVCodecParameters` and set its fields to default values (unknown/invalid/0).
    public init() {
        guard let ptr = avcodec_parameters_alloc() else {
            abort("avcodec_parameters_alloc")
        }
        self.cParametersPtr = ptr
        self.freeWhenDone = true
    }

    deinit {
        if freeWhenDone {
            var ps: UnsafeMutablePointer<CAVCodecParameters>? = cParametersPtr
            avcodec_parameters_free(&ps)
        }
    }

    /// General type of the encoded data.
    public var mediaType: AVMediaType {
        get { return cParameters.codec_type }
        set { cParametersPtr.pointee.codec_type = newValue }
    }

    /// Specific type of the encoded data (the codec used).
    public var codecId: AVCodecID {
        get { return cParameters.codec_id }
        set { cParametersPtr.pointee.codec_id = newValue }
    }

    /// Additional information about the codec (corresponds to the AVI FOURCC).
    public var codecTag: UInt32 {
        get { return cParameters.codec_tag }
        set { cParametersPtr.pointee.codec_tag = newValue }
    }

    /// The average bitrate of the encoded data (in bits per second).
    public var bitRate: Int64 {
        get { return cParameters.bit_rate }
        set { cParametersPtr.pointee.bit_rate = newValue }
    }

    /// Copy the contents from the supplied codec parameters.
    public func copy(from codecpar: AVCodecParameters) {
        abortIfFail(avcodec_parameters_copy(cParametersPtr, codecpar.cParametersPtr))
    }

    /// Fill the parameters struct based on the values from the supplied codec context.
    public func copy(from codecCtx: AVCodecContext) {
        abortIfFail(avcodec_parameters_from_context(cParametersPtr, codecCtx.cContextPtr))
    }
}

// MARK: - Video

extension AVCodecParameters {

    /// The pixel format of the video frame.
    public var pixelFormat: AVPixelFormat {
        get { return AVPixelFormat(cParameters.format) }
        set { cParametersPtr.pointee.format = newValue.rawValue }
    }

    /// The width of the video frame in pixels.
    public var width: Int {
        get { return Int(cParameters.width) }
        set { cParametersPtr.pointee.width = Int32(newValue) }
    }

    /// The height of the video frame in pixels.
    public var height: Int {
        get { return Int(cParameters.height) }
        set { cParametersPtr.pointee.height = Int32(newValue) }
    }

    /// The aspect ratio (width / height) which a single pixel should have when displayed.
    ///
    /// When the aspect ratio is unknown / undefined, the numerator should be set to 0
    /// (the denominator may have any value).
    public var sampleAspectRatio: AVRational {
        get { return cParameters.sample_aspect_ratio }
        set { cParametersPtr.pointee.sample_aspect_ratio = newValue }
    }

    /// Number of delayed frames.
    public var videoDelay: Int {
        get { return Int(cParameters.video_delay) }
        set { cParametersPtr.pointee.video_delay = Int32(newValue) }
    }
}

// MARK: - Audio

extension AVCodecParameters {

    /// The sample format of audio.
    public var sampleFormat: AVSampleFormat {
        get { return AVSampleFormat(cParameters.format) }
        set { cParametersPtr.pointee.format = newValue.rawValue }
    }

    /// The channel layout bitmask. May be 0 if the channel layout is unknown or unspecified,
    /// otherwise the number of bits set must be equal to the channels field.
    public var channelLayout: AVChannelLayout {
        get { return AVChannelLayout(rawValue: cParameters.channel_layout) }
        set { cParametersPtr.pointee.channel_layout = newValue.rawValue }
    }

    /// The number of audio channels.
    public var channelCount: Int {
        get { return Int(cParameters.channels) }
        set { cParametersPtr.pointee.channels = Int32(newValue) }
    }

    /// The number of audio samples per second.
    public var sampleRate: Int {
        get { return Int(cParameters.sample_rate) }
        set { cParametersPtr.pointee.sample_rate = Int32(newValue) }
    }

    /// Audio frame size, if known. Required by some formats to be static.
    public var frameSize: Int {
        get { return Int(cParameters.frame_size) }
        set { cParametersPtr.pointee.frame_size = Int32(newValue) }
    }
}

// MARK: - AVStream

typealias CAVStream = CFFmpeg.AVStream

/// Stream structure.
public final class AVStream {
    let cStreamPtr: UnsafeMutablePointer<CAVStream>
    var cStream: CAVStream { return cStreamPtr.pointee }

    init(cStreamPtr: UnsafeMutablePointer<CAVStream>) {
        self.cStreamPtr = cStreamPtr
    }

    /// Format-specific stream ID.
    ///
    /// - encoding: Set by the user, replaced by libavformat if left unset.
    /// - decoding: Set by libavformat.
    public var id: Int32 {
        get { return cStream.id }
        set { cStreamPtr.pointee.id = newValue }
    }

    /// Stream index in `AVFormatContext`.
    public var index: Int {
        return Int(cStream.index)
    }

    /// This is the fundamental unit of time (in seconds) in terms of which frame timestamps are represented.
    ///
    /// - encoding: May be set by the caller before `writeHeader` to provide a hint to the muxer about
    ///   the desired timebase. In `writeHeader`, the muxer will overwrite this field with the timebase
    ///   that will actually be used for the timestamps written into the file (which may or may not be related to
    ///   the user-provided one, depending on the format).
    /// - decoding: Set by libavformat.
    public var timebase: AVRational {
        get { return cStream.time_base }
        set { cStreamPtr.pointee.time_base = newValue }
    }

    /// pts of the first frame of the stream in presentation order, in stream timebase.
    public var startTime: Int64 {
        return cStream.start_time
    }

    public var duration: Int64 {
        return cStream.duration
    }

    /// Number of frames in this stream if known or 0.
    public var frameCount: Int {
        return Int(cStream.nb_frames)
    }

    /// Selects which packets can be discarded at will and do not need to be demuxed.
    public var discard: AVDiscard {
        get { return cStream.discard }
        set { cStreamPtr.pointee.discard = newValue }
    }

    /// sample aspect ratio (0 if unknown)
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by libavformat.
    public var sampleAspectRatio: AVRational {
        return cStream.sample_aspect_ratio
    }

    /// The metadata of the stream.
    public var metadata: [String: String] {
        var dict = [String: String]()
        var tag: UnsafeMutablePointer<AVDictionaryEntry>?
        while let next = av_dict_get(cStream.metadata, "", tag, AV_DICT_IGNORE_SUFFIX) {
            dict[String(cString: next.pointee.key)] = String(cString: next.pointee.value)
            tag = next
        }
        return dict
    }

    /// Average framerate.
    ///
    /// - demuxing: May be set by libavformat when creating the stream or in `findStreamInfo`.
    /// - muxing: May be set by the caller before `writeHeader`.
    public var averageFramerate: AVRational {
        return cStream.avg_frame_rate
    }

    /// Real base framerate of the stream.
    /// This is the lowest framerate with which all timestamps can be represented accurately
    /// (it is the least common multiple of all framerates in the stream). Note, this value is just a guess!
    /// For example, if the time base is 1/90000 and all frames have either approximately 3600 or 1800 timer ticks,
    /// then realFramerate will be 50/1.
    public var realFramerate: AVRational {
        return cStream.r_frame_rate
    }

    /// Codec parameters associated with this stream.
    ///
    /// - demuxing: Filled by libavformat on stream creation or in `findStreamInfo`.
    /// - muxing: Filled by the caller before `writeHeader`.
    public var codecParameters: AVCodecParameters {
        return AVCodecParameters(cParametersPtr: cStream.codecpar)
    }

    /// The media type of the stream.
    public var mediaType: AVMediaType {
        return codecParameters.mediaType
    }
}
