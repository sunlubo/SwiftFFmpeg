//
//  AVCodecContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

internal typealias CAVCodecContext = CFFmpeg.AVCodecContext

public final class AVCodecContext {
    public let codec: AVCodec

    internal let ctxPtr: UnsafeMutablePointer<CAVCodecContext>
    internal var ctx: CAVCodecContext { return ctxPtr.pointee }

    /// Allocate an AVCodecContext and set its fields to default values.
    ///
    /// - Parameter codec: codec
    public init?(codec: AVCodec) {
        self.codec = codec

        guard let ctxPtr = avcodec_alloc_context3(codec.codecPtr) else {
            return nil
        }
        self.ctxPtr = ctxPtr
    }

    public var codecType: AVMediaType {
        return ctx.codec_type
    }

    public var codecId: AVCodecID {
        get { return ctx.codec_id }
        set { ctxPtr.pointee.codec_id = newValue }
    }

    public var codecTag: UInt32 {
        get { return ctx.codec_tag }
        set { ctxPtr.pointee.codec_tag = newValue }
    }

    /// the average bitrate
    /// - encoding: Set by user; unused for constant quantizer encoding.
    /// - decoding: Set by user, may be overwritten by libavcodec if this info is available in the stream.
    public var bitRate: Int64 {
        get { return ctx.bit_rate }
        set { ctxPtr.pointee.bit_rate = newValue }
    }

    /// AVCodecFlag
    public var flags: Int32 {
        get { return ctx.flags }
        set { ctxPtr.pointee.flags = newValue }
    }

    /// AVCodecFlag2
    public var flags2: Int32 {
        get { return ctx.flags2 }
        set { ctxPtr.pointee.flags2 = newValue }
    }

    /// This is the fundamental unit of time (in seconds) in terms of which frame timestamps are represented.
    public var timeBase: AVRational {
        get { return ctx.time_base }
        set { ctxPtr.pointee.time_base = newValue }
    }

    /// Frame counter
    ///
    /// - decoding: total number of frames returned from the decoder so far.
    /// - encoding: total number of frames passed to the encoder so far.
    public var frameNumber: Int {
        return Int(ctx.frame_number)
    }

    public var isOpen: Bool {
        return avcodec_is_open(ctxPtr) > 0
    }

    /// Sets an option on the `AVCodecContext`.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - key: the name of the field to set
    ///   - searchFlags: flags passed to av_opt_find2.
    ////    I.e. if AV_OPT_SEARCH_CHILDREN is passed here, then the option may be set on a child of obj.
    /// - Throws: AVError
    public func setOption(_ value: String, forKey key: String, searchFlags: Int32 = 0) throws {
        try throwIfFail(av_opt_set(ctx.priv_data, key, value, searchFlags))
    }

    /// Fill the codec context based on the values from the supplied codec parameters.
    ///
    /// - Parameter params: parameters
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
    /// - Throws: AVError
    public func sendPacket(_ packet: AVPacket?) throws {
        try throwIfFail(avcodec_send_packet(ctxPtr, packet?.packetPtr))
    }

    /// Return decoded output data from a decoder.
    ///
    /// - Parameter frame: This will be set to a reference-counted video or audio frame (depending on the decoder type) allocated by the decoder.
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
    /// - Returns:
    ///   - `AVError.EAGAIN`: input is not accepted in the current state - user must read output with avcodec_receive_packet() (once
    ///     all output is read, the packet should be resent, and the call will not fail with EAGAIN).
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
        let ps = UnsafeMutablePointer<UnsafeMutablePointer<CAVCodecContext>?>.allocate(capacity: 1)
        ps.initialize(to: ctxPtr)
        avcodec_free_context(ps)
        ps.deallocate()
    }
}

// MARK: - Video

extension AVCodecContext {

    /// picture width
    public var width: Int {
        get { return Int(ctx.width) }
        set { ctxPtr.pointee.width = Int32(newValue) }
    }

    /// picture height
    public var height: Int {
        get { return Int(ctx.height) }
        set { ctxPtr.pointee.height = Int32(newValue) }
    }

    /// Bitstream width, may be different from `width` e.g. when
    /// the decoded frame is cropped before being output or lowres is enabled.
    public var codedWidth: Int {
        get { return Int(ctx.coded_width) }
        set { ctxPtr.pointee.coded_width = Int32(newValue) }
    }

    /// Bitstream height, may be different from `height` e.g. when
    /// the decoded frame is cropped before being output or lowres is enabled.
    public var codedHeight: Int {
        get { return Int(ctx.coded_height) }
        set { ctxPtr.pointee.coded_height = Int32(newValue) }
    }

    /// the number of pictures in a group of pictures, or 0 for intra_only
    public var gopSize: Int32 {
        get { return ctx.gop_size }
        set { ctxPtr.pointee.gop_size = newValue }
    }

    /// Pixel format
    public var pixFmt: AVPixelFormat {
        get { return ctx.pix_fmt }
        set { ctxPtr.pointee.pix_fmt = newValue }
    }

    /// maximum number of B-frames between non-B-frames
    public var maxBFrames: Int32 {
        get { return ctx.max_b_frames }
        set { ctxPtr.pointee.max_b_frames = newValue }
    }

    /// macroblock decision mode
    public var mbDecision: Int32 {
        get { return ctx.mb_decision }
        set { ctxPtr.pointee.mb_decision = newValue }
    }

    /// sample aspect ratio (0 if unknown)
    /// That is the width of a pixel divided by the height of the pixel.
    /// Numerator and denominator must be relatively prime and smaller than 256 for some video standards.
    public var sampleAspectRatio: AVRational {
        get { return ctx.sample_aspect_ratio }
        set { ctxPtr.pointee.sample_aspect_ratio = newValue }
    }

    public var framerate: AVRational {
        get { return ctx.framerate }
        set { ctxPtr.pointee.framerate = newValue }
    }
}

// MARK: - Audio

extension AVCodecContext {

    /// samples per second
    public var sampleRate: Int32 {
        get { return ctx.sample_rate }
        set { ctxPtr.pointee.sample_rate = newValue }
    }

    /// number of audio channels
    public var channels: Int32 {
        get { return ctx.channels }
        set { ctxPtr.pointee.channels = newValue }
    }

    /// audio sample format
    public var sampleFmt: AVSampleFormat {
        get { return ctx.sample_fmt }
        set { ctxPtr.pointee.sample_fmt = newValue }
    }

    /// Number of samples per channel in an audio frame.
    public var frameSize: Int32 {
        return ctx.frame_size
    }

    /// Audio channel layout.
    public var channelLayout: UInt64 {
        get { return ctx.channel_layout }
        set { ctxPtr.pointee.channel_layout = newValue }
    }
}
