//
//  AVCodecContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVCodecFlag

/// encoding support
///
/// These flags can be passed in AVCodecContext.flags before initialization.
public struct AVCodecFlag {
    /// Place global headers in extradata instead of every keyframe.
    public static let globalHeader = AV_CODEC_FLAG_GLOBAL_HEADER
}

// MARK: - AVCodecContext

internal typealias CAVCodecContext = CFFmpeg.AVCodecContext

public final class AVCodecContext {
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
    public var bitRate: Int64 {
        get { return ctx.bit_rate }
        set { ctxPtr.pointee.bit_rate = newValue }
    }

    /// - encoding: Set by user.
    /// - decoding: Set by user.
    ///
    /// - SeeAlso: `AVCodecFlag`
    public var flags: Int32 {
        get { return ctx.flags }
        set { ctxPtr.pointee.flags = newValue }
    }

    /// - encoding: Set by user.
    /// - decoding: Set by user.
    ///
    /// - SeeAlso: `AVCodecFlag2`
    public var flags2: Int32 {
        get { return ctx.flags2 }
        set { ctxPtr.pointee.flags2 = newValue }
    }

    /// This is the fundamental unit of time (in seconds) in terms of which frame timestamps are represented.
    /// For fixed-fps content, timebase should be 1/framerate and timestamp increments should be identically 1.
    ///
    /// This often, but not always is the inverse of the frame rate or field rate for video.
    /// 1/time_base is not the average frame rate if the frame rate is not constant.
    ///
    /// - decoding: Must be set by user.
    /// - encoding: The use of this field for decoding is deprecated. Use framerate instead.
    public var timebase: AVRational {
        get { return ctx.time_base }
        set { ctxPtr.pointee.time_base = newValue }
    }

    /// Frame counter.
    ///
    /// - decoding: Total number of frames returned from the decoder so far.
    /// - encoding: Total number of frames passed to the encoder so far.
    public var frameNumber: Int {
        return Int(ctx.frame_number)
    }

    /// Returns a Boolean value indicating whether the codec is open.
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
    /// - Parameter packet: The input `AVPacket`. Usually, this will be a single video frame, or several complete audio frames.
    ///   It can be `nil` (or an `AVPacket` with data set to `nil` and size set to 0); in this case, it is considered a
    ///   flush packet, which signals the end of the stream. Sending the first flush packet will return success.
    ///   Subsequent ones are unnecessary and will return `AVError.EOF`. If the decoder still has frames buffered,
    ///   it will return them after sending a flush packet.
    /// - Throws: AVError
    public func sendPacket(_ packet: AVPacket?) throws {
        try throwIfFail(avcodec_send_packet(ctxPtr, packet?.packetPtr))
    }

    /// Return decoded output data from a decoder.
    ///
    /// - Parameter frame: This will be set to a reference-counted video or audio frame (depending on the decoder type)
    ///   allocated by the decoder.
    /// - Throws:
    ///   - `AVError.EAGAIN`: output is not available in this state - user must try to send new input
    ///   - `AVError.EOF`: the decoder has been fully flushed, and there will be no more output frames
    ///   - `AVError.EINVAL`: codec not opened, or it is an encoder
    ///   - other error: legitimate decoding errors
    public func receiveFrame(_ frame: AVFrame) throws {
        try throwIfFail(avcodec_receive_frame(ctxPtr, frame.framePtr))
    }

    /// Supply a raw video or audio frame to the encoder.
    ///
    /// - Parameter frame: AVFrame containing the raw audio or video frame to be encoded.
    ///   It can be NULL, in which case it is considered a flush packet. This signals the end of the stream.
    ///   If the encoder still has packets buffered, it will return them after this call. Once flushing mode has been
    ///   entered, additional flush packets are ignored, and sending frames will return `AVError.EOF`.
    /// - Returns:
    ///   - `AVError.EAGAIN`: input is not accepted in the current state - user must read output with `receivePacket(_:)`
    ///     (once all output is read, the packet should be resent, and the call will not fail with `AVError.EAGAIN`).
    ///   - `AVError.EOF`: the encoder has been flushed, and no new frames can be sent to it
    ///   - `AVError.EINVAL`: codec not opened, refcounted_frames not set, it is a decoder, or requires flush
    ///   - `AVError.ENOMEM`: failed to add packet to internal queue, or similar
    ///   - other errors: legitimate decoding errors
    public func sendFrame(_ frame: AVFrame?) throws {
        try throwIfFail(avcodec_send_frame(ctxPtr, frame?.framePtr))
    }

    /// Read encoded data from the encoder.
    ///
    /// - Parameter packet: This will be set to a reference-counted packet allocated by the encoder.
    /// - Returns:
    ///   - `AVError.EAGAIN`: output is not available in the current state - user must try to send input
    ///   - `AVError.EOF`: the encoder has been fully flushed, and there will be no more output packets
    ///   - `AVError.EINVAL`: codec not opened, or it is an encoder
    ///   - other errors: legitimate decoding errors
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
    /// - decoding: Must be set by user.
    /// - encoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   Some decoders will require the dimensions to be set by the caller. During decoding, the decoder may
    ///   overwrite those values as required while parsing the data.
    public var width: Int {
        get { return Int(ctx.width) }
        set { ctxPtr.pointee.width = Int32(newValue) }
    }

    /// picture height
    ///
    /// - decoding: Must be set by user.
    /// - encoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   Some decoders will require the dimensions to be set by the caller. During decoding, the decoder may
    ///   overwrite those values as required while parsing the data.
    public var height: Int {
        get { return Int(ctx.height) }
        set { ctxPtr.pointee.height = Int32(newValue) }
    }

    /// Bitstream width, may be different from `width` e.g. when
    /// the decoded frame is cropped before being output or lowres is enabled.
    ///
    /// - decoding: Unused.
    /// - encoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   During decoding, the decoder may overwrite those values as required while parsing the data.
    public var codedWidth: Int {
        get { return Int(ctx.coded_width) }
        set { ctxPtr.pointee.coded_width = Int32(newValue) }
    }

    /// Bitstream height, may be different from `height` e.g. when
    /// the decoded frame is cropped before being output or lowres is enabled.
    ///
    /// - decoding: Unused.
    /// - encoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   During decoding, the decoder may overwrite those values as required while parsing the data.
    public var codedHeight: Int {
        get { return Int(ctx.coded_height) }
        set { ctxPtr.pointee.coded_height = Int32(newValue) }
    }

    /// The number of pictures in a group of pictures, or 0 for intra_only.
    ///
    /// - decoding: Set by user.
    /// - encoding: Unused.
    public var gopSize: Int32 {
        get { return ctx.gop_size }
        set { ctxPtr.pointee.gop_size = newValue }
    }

    /// Pixel format.
    ///
    /// - decoding: Set by user.
    /// - encoding: Set by user if known, overridden by codec while parsing the data.
    public var pixFmt: AVPixelFormat {
        get { return ctx.pix_fmt }
        set { ctxPtr.pointee.pix_fmt = newValue }
    }

    /// Maximum number of B-frames between non-B-frames.
    ///
    /// - decoding: Set by user.
    /// - encoding: Unused.
    public var maxBFrames: Int32 {
        get { return ctx.max_b_frames }
        set { ctxPtr.pointee.max_b_frames = newValue }
    }

    /// Macroblock decision mode.
    ///
    /// - decoding: Set by user.
    /// - encoding: Unused.
    public var mbDecision: Int32 {
        get { return ctx.mb_decision }
        set { ctxPtr.pointee.mb_decision = newValue }
    }

    /// Sample aspect ratio (0 if unknown).
    ///
    /// That is the width of a pixel divided by the height of the pixel.
    /// Numerator and denominator must be relatively prime and smaller than 256 for some video standards.
    ///
    /// - decoding: Set by user.
    /// - encoding: Set by codec.
    public var sampleAspectRatio: AVRational {
        get { return ctx.sample_aspect_ratio }
        set { ctxPtr.pointee.sample_aspect_ratio = newValue }
    }

    /// Framerate.
    ///
    /// - decoding: For codecs that store a framerate value in the compressed bitstream, the decoder may export it here.
    ///   {0, 1} when unknown.
    /// - encoding: May be used to signal the framerate of CFR content to an encoder.
    public var framerate: AVRational {
        get { return ctx.framerate }
        set { ctxPtr.pointee.framerate = newValue }
    }
}

// MARK: - Audio

extension AVCodecContext {

    /// Samples per second.
    public var sampleRate: Int32 {
        get { return ctx.sample_rate }
        set { ctxPtr.pointee.sample_rate = newValue }
    }

    /// Number of audio channels.
    public var channels: Int32 {
        get { return ctx.channels }
        set { ctxPtr.pointee.channels = newValue }
    }

    /// Audio sample format.
    public var sampleFmt: AVSampleFormat {
        get { return ctx.sample_fmt }
        set { ctxPtr.pointee.sample_fmt = newValue }
    }

    /// Number of samples per channel in an audio frame.
    public var frameSize: Int32 {
        return ctx.frame_size
    }

    /// Audio channel layout.
    ///
    /// - decoding: Set by user.
    /// - encoding: Set by user, may be overwritten by codec.
    public var channelLayout: UInt64 {
        get { return ctx.channel_layout }
        set { ctxPtr.pointee.channel_layout = newValue }
    }
}
