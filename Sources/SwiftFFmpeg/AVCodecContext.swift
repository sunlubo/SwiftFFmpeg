//
//  AVCodecContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg
import Darwin.C

// MARK: - AVCodecContext

internal typealias CAVCodecContext = CFFmpeg.AVCodecContext

public final class AVCodecContext {
    /// Encoding support
    ///
    /// These flags can be passed in `flags` before initialization.
    public struct Flag: OptionSet {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Place global headers in extradata instead of every keyframe.
        public static let globalHeader = Flag(rawValue: AV_CODEC_FLAG_GLOBAL_HEADER)
    }

    /// Encoding support
    ///
    /// These flags can be passed in `flags2` before initialization.
    public struct Flag2: OptionSet {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Allow non spec compliant speedup tricks.
        public static let fast = Flag2(rawValue: AV_CODEC_FLAG2_FAST)
        /// Skip bitstream encoding.
        public static let noOutput = Flag2(rawValue: AV_CODEC_FLAG2_NO_OUTPUT)
        /// Place global headers at every keyframe instead of in extradata.
        public static let localHeader = Flag2(rawValue: AV_CODEC_FLAG2_LOCAL_HEADER)
        /// Input bitstream might be truncated at a packet boundaries instead of only at frame boundaries.
        public static let chunks = Flag2(rawValue: AV_CODEC_FLAG2_CHUNKS)
        /// Discard cropping information from SPS.
        public static let ignoreCrop = Flag2(rawValue: AV_CODEC_FLAG2_IGNORE_CROP)
        /// Show all frames before the first keyframe.
        public static let showAll = Flag2(rawValue: AV_CODEC_FLAG2_SHOW_ALL)
        /// Export motion vectors through frame side data.
        public static let exportMVS = Flag2(rawValue: AV_CODEC_FLAG2_EXPORT_MVS)
        /// Do not skip samples and export skip information as frame side data.
        public static let skipManual = Flag2(rawValue: AV_CODEC_FLAG2_SKIP_MANUAL)
        /// Do not reset ASS ReadOrder field on flush (subtitles decoding).
        public static let roFlushNoop = Flag2(rawValue: AV_CODEC_FLAG2_RO_FLUSH_NOOP)
    }

    public let codec: AVCodec

    internal let ctxPtr: UnsafeMutablePointer<CAVCodecContext>
    internal var ctx: CAVCodecContext { return ctxPtr.pointee }

    /// Creates an `AVCodecContext` from the given codec.
    ///
    /// - Parameter codec: codec
    public init?(codec: AVCodec) {
        guard let ctxPtr = avcodec_alloc_context3(codec.codecPtr) else {
            return nil
        }
        self.codec = codec
        self.ctxPtr = ctxPtr
    }

    /// The codec's media type.
    public var mediaType: AVMediaType {
        return ctx.codec_type
    }

    /// The codec's id.
    public var codecId: AVCodecID {
        get { return ctx.codec_id }
        set { ctxPtr.pointee.codec_id = newValue }
    }

    /// The codec's tag.
    public var codecTag: UInt32 {
        get { return ctx.codec_tag }
        set { ctxPtr.pointee.codec_tag = newValue }
    }

    /// The average bitrate.
    ///
    /// - encoding: Set by user; unused for constant quantizer encoding.
    /// - decoding: Set by user, may be overwritten by libavcodec if this info is available in the stream.
    public var bitRate: Int {
        get { return Int(ctx.bit_rate) }
        set { ctxPtr.pointee.bit_rate = Int64(newValue) }
    }

    /// - encoding: Set by user.
    /// - decoding: Set by user.
    public var flags: AVCodecContext.Flag {
        get { return Flag(rawValue: ctx.flags) }
        set { ctxPtr.pointee.flags = newValue.rawValue }
    }

    /// - encoding: Set by user.
    /// - decoding: Set by user.
    public var flags2: AVCodecContext.Flag2 {
        get { return Flag2(rawValue: ctx.flags2) }
        set { ctxPtr.pointee.flags2 = newValue.rawValue }
    }

    /// This is the fundamental unit of time (in seconds) in terms of which frame timestamps are represented.
    /// For fixed-fps content, timebase should be 1/framerate and timestamp increments should be identically 1.
    /// This often, but not always is the inverse of the frame rate or field rate for video.
    /// 1/time_base is not the average frame rate if the frame rate is not constant.
    ///
    /// - encoding: Must be set by user.
    /// - decoding: The use of this field for decoding is deprecated. Use framerate instead.
    public var timebase: AVRational {
        get { return ctx.time_base }
        set { ctxPtr.pointee.time_base = newValue }
    }

    /// Frame counter.
    ///
    /// - encoding: Total number of frames passed to the encoder so far.
    /// - decoding: Total number of frames returned from the decoder so far.
    public var frameNumber: Int {
        return Int(ctx.frame_number)
    }

    /// A Boolean value indicating whether the codec is open.
    public var isOpen: Bool {
        return avcodec_is_open(ctxPtr) > 0
    }

    /// Fill the codec context based on the values from the supplied codec parameters.
    ///
    /// Any allocated fields in codec that have a corresponding field in par are freed and replaced with duplicates
    /// of the corresponding field in par. Fields in codec that do not have a counterpart in par are not touched.
    ///
    /// - Parameter params: codec parameters
    /// - Throws: AVError
    public func setParameters(_ params: AVCodecParameters) throws {
        try throwIfFail(avcodec_parameters_to_context(ctxPtr, params.parametersPtr))
    }

    /// Initialize the `AVCodecContext` to use the given `AVCodec`.
    ///
    /// - Parameters:
    ///   - options: A dictionary filled with `AVCodecContext` and codec-private options.
    /// - Throws: AVError
    public func openCodec(options: [String: String]? = nil) throws {
        var pm: OpaquePointer?
        defer { av_dict_free(&pm) }
        if let options = options {
            for (k, v) in options {
                av_dict_set(&pm, k, v, 0)
            }
        }

        try throwIfFail(avcodec_open2(ctxPtr, codec.codecPtr, &pm))

        dumpUnrecognizedOptions(pm)
    }

    /// Supply raw packet data as input to a decoder.
    ///
    /// - Parameter packet: The input `AVPacket`. Usually, this will be a single video frame, or several complete
    ///   audio frames. It can be `nil` (or an `AVPacket` with data set to `nil` and size set to 0); in this case,
    ///   it is considered a flush packet, which signals the end of the stream. Sending the first flush packet will
    ///   return success. Subsequent ones are unnecessary and will return `AVError.EOF`. If the decoder still has
    ///   frames buffered, it will return them after sending a flush packet.
    /// - Throws: AVError
    public func sendPacket(_ packet: AVPacket?) throws {
        try throwIfFail(avcodec_send_packet(ctxPtr, packet?.packetPtr))
    }

    /// Return decoded output data from a decoder.
    ///
    /// - Parameter frame: This will be set to a reference-counted video or audio frame (depending on the decoder type)
    ///   allocated by the decoder.
    /// - Throws:
    ///     - `AVError.EAGAIN` if output is not available in this state - user must try to send new input
    ///     - `AVError.EOF` if the decoder has been fully flushed, and there will be no more output frames
    ///     - `AVError.EINVAL` if codec not opened, or it is an encoder
    ///     - legitimate decoding errors
    public func receiveFrame(_ frame: AVFrame) throws {
        try throwIfFail(avcodec_receive_frame(ctxPtr, frame.framePtr))
    }

    /// Supply a raw video or audio frame to the encoder.
    ///
    /// - Parameter frame: `AVFrame` containing the raw audio or video frame to be encoded.
    ///   It can be nil, in which case it is considered a flush packet. This signals the end of the stream.
    ///   If the encoder still has packets buffered, it will return them after this call. Once flushing mode has been
    ///   entered, additional flush packets are ignored, and sending frames will return `AVError.EOF`.
    /// - Throws:
    ///     - `AVError.EAGAIN`: input is not accepted in the current state - user must read output with `receivePacket`.
    ///       (once all output is read, the packet should be resent, and the call will not fail with `AVError.EAGAIN`).
    ///     - `AVError.EOF` if the encoder has been flushed, and no new frames can be sent to it
    ///     - `AVError.EINVAL` if codec not opened, refcounted_frames not set, it is a decoder, or requires flush
    ///     - `AVError.ENOMEM` if failed to add packet to internal queue, or similar
    ///     - legitimate decoding errors
    public func sendFrame(_ frame: AVFrame?) throws {
        try throwIfFail(avcodec_send_frame(ctxPtr, frame?.framePtr))
    }

    /// Read encoded data from the encoder.
    ///
    /// - Parameter packet: This will be set to a reference-counted packet allocated by the encoder.
    /// - Throws:
    ///     - `AVError.EAGAIN` if output is not available in the current state - user must try to send input
    ///     - `AVError.EOF` if the encoder has been fully flushed, and there will be no more output packets
    ///     - `AVError.EINVAL` if codec not opened, or it is an encoder
    ///     - legitimate decoding errors
    public func receivePacket(_ packet: AVPacket) throws {
        try throwIfFail(avcodec_receive_packet(ctxPtr, packet.packetPtr))
    }

    deinit {
        var ps: UnsafeMutablePointer<CAVCodecContext>? = ctxPtr
        avcodec_free_context(&ps)
    }
}

// MARK: - Video

extension AVCodecContext {

    /// picture width
    ///
    /// - encoding: Must be set by user.
    /// - decoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   Some decoders will require the dimensions to be set by the caller. During decoding, the decoder may
    ///   overwrite those values as required while parsing the data.
    public var width: Int {
        get { return Int(ctx.width) }
        set { ctxPtr.pointee.width = Int32(newValue) }
    }

    /// picture height
    ///
    /// - encoding: Must be set by user.
    /// - decoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   Some decoders will require the dimensions to be set by the caller. During decoding, the decoder may
    ///   overwrite those values as required while parsing the data.
    public var height: Int {
        get { return Int(ctx.height) }
        set { ctxPtr.pointee.height = Int32(newValue) }
    }

    /// Bitstream width, may be different from `width` e.g. when
    /// the decoded frame is cropped before being output or lowres is enabled.
    ///
    /// - encoding: Unused.
    /// - decoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   During decoding, the decoder may overwrite those values as required while parsing the data.
    public var codedWidth: Int {
        get { return Int(ctx.coded_width) }
        set { ctxPtr.pointee.coded_width = Int32(newValue) }
    }

    /// Bitstream height, may be different from `height` e.g. when
    /// the decoded frame is cropped before being output or lowres is enabled.
    ///
    /// - encoding: Unused.
    /// - decoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   During decoding, the decoder may overwrite those values as required while parsing the data.
    public var codedHeight: Int {
        get { return Int(ctx.coded_height) }
        set { ctxPtr.pointee.coded_height = Int32(newValue) }
    }

    /// The number of pictures in a group of pictures, or 0 for intra_only.
    ///
    /// - encoding: Set by user.
    /// - decoding: Unused.
    public var gopSize: Int {
        get { return Int(ctx.gop_size) }
        set { ctxPtr.pointee.gop_size = Int32(newValue) }
    }

    /// Pixel format.
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by user if known, overridden by codec while parsing the data.
    public var pixFmt: AVPixelFormat {
        get { return ctx.pix_fmt }
        set { ctxPtr.pointee.pix_fmt = newValue }
    }

    /// Maximum number of B-frames between non-B-frames.
    ///
    /// - Note: The output will be delayed by max_b_frames+1 relative to the input.
    ///
    /// - encoding: Set by user.
    /// - decoding: Unused.
    public var maxBFrames: Int {
        get { return Int(ctx.max_b_frames) }
        set { ctxPtr.pointee.max_b_frames = Int32(newValue) }
    }

    /// Macroblock decision mode.
    ///
    /// - encoding: Set by user.
    /// - decoding: Unused.
    public var mbDecision: Int {
        get { return Int(ctx.mb_decision) }
        set { ctxPtr.pointee.mb_decision = Int32(newValue) }
    }

    /// Sample aspect ratio (0 if unknown).
    ///
    /// That is the width of a pixel divided by the height of the pixel.
    /// Numerator and denominator must be relatively prime and smaller than 256 for some video standards.
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by codec.
    public var sampleAspectRatio: AVRational {
        get { return ctx.sample_aspect_ratio }
        set { ctxPtr.pointee.sample_aspect_ratio = newValue }
    }

    /// low resolution decoding, 1-> 1/2 size, 2->1/4 size
    ///
    /// - encoding: Unused.
    /// - decoding: Set by user.
    public var lowres: Int32 {
        return ctx.lowres
    }

    /// Framerate.
    ///
    /// - encoding: May be used to signal the framerate of CFR content to an encoder.
    /// - decoding: For codecs that store a framerate value in the compressed bitstream, the decoder may export it here.
    ///   {0, 1} when unknown.
    public var framerate: AVRational {
        get { return ctx.framerate }
        set { ctxPtr.pointee.framerate = newValue }
    }
}

// MARK: - Audio

extension AVCodecContext {

    /// Samples per second.
    public var sampleRate: Int {
        get { return Int(ctx.sample_rate) }
        set { ctxPtr.pointee.sample_rate = Int32(newValue) }
    }

    /// Number of audio channels.
    public var channelCount: Int {
        get { return Int(ctx.channels) }
        set { ctxPtr.pointee.channels = Int32(newValue) }
    }

    /// Audio sample format.
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by libavcodec.
    public var sampleFmt: AVSampleFormat {
        get { return ctx.sample_fmt }
        set { ctxPtr.pointee.sample_fmt = newValue }
    }

    /// Number of samples per channel in an audio frame.
    public var frameSize: Int {
        get { return Int(ctx.frame_size) }
        set { ctxPtr.pointee.frame_size = Int32(newValue) }
    }

    /// Audio channel layout.
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by user, may be overwritten by codec.
    public var channelLayout: AVChannelLayout {
        get { return AVChannelLayout(rawValue: ctx.channel_layout) }
        set { ctxPtr.pointee.channel_layout = newValue.rawValue }
    }
}
