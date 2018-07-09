//
//  AVStream.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

internal typealias CAVCodecParameters = CFFmpeg.AVCodecParameters

/// This class describes the properties of an encoded stream.
public final class AVCodecParameters {
    internal let parametersPtr: UnsafeMutablePointer<CAVCodecParameters>
    internal var parameters: CAVCodecParameters { return parametersPtr.pointee }
    
    internal init(parametersPtr: UnsafeMutablePointer<CAVCodecParameters>) {
        self.parametersPtr = parametersPtr
    }
    
    /// General type of the encoded data.
    public var codecType: AVMediaType {
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
    
    /// - video: the pixel format, the value corresponds to AVPixelFormat.
    /// - audio: the sample format, the value corresponds to AVSampleFormat.
    public var format: Int32 {
        return parameters.format
    }
    
    /// The average bitrate of the encoded data (in bits per second).
    public var bitRate: Int64 {
        return parameters.bit_rate
    }
    
    /// Video only. The width of the video frame in pixels.
    public var width: Int {
        return Int(parameters.width)
    }
    
    /// Video only. The height of the video frame in pixels.
    public var height: Int {
        return Int(parameters.height)
    }
    
    /// Video only. The aspect ratio (width / height) which a single pixel should have when displayed.
    ///
    /// When the aspect ratio is unknown / undefined, the numerator should be
    /// set to 0 (the denominator may have any value).
    public var sampleAspectRatio: AVRational {
        return parameters.sample_aspect_ratio
    }
    
    /// Video only. Number of delayed frames.
    public var videoDelay: Int32 {
        return parameters.video_delay
    }
    
    /// Audio only. The channel layout bitmask. May be 0 if the channel layout is
    /// unknown or unspecified, otherwise the number of bits set must be equal to
    /// the channels field.
    public var channelLayout: UInt64 {
        return parameters.channel_layout
    }
    
    /// Audio only. The number of audio channels.
    public var channels: Int {
        return Int(parameters.channels)
    }
    
    /// Audio only. The number of audio samples per second.
    public var sampleRate: Int32 {
        return parameters.sample_rate
    }
    
    /// Audio only. Audio frame size, if known. Required by some formats to be static.
    public var frameSize: Int32 {
        return parameters.frame_size
    }
}

internal typealias CAVStream = CFFmpeg.AVStream

/// Stream structure.
public struct AVStream {
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
    public var timeBase: AVRational {
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
    
    /// sample aspect ratio (0 if unknown)
    public var sampleAspectRatio: AVRational {
        return stream.sample_aspect_ratio
    }
    
    /// Codec parameters associated with this stream.
    public var codecpar: AVCodecParameters {
        return AVCodecParameters(parametersPtr: stream.codecpar)
    }
    
    public var codecType: AVMediaType {
        return codecpar.codecType
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
    
    /// Fill the parameters struct based on the values from the supplied codec context.
    ///
    /// - Parameter codecCtx: AVCodecContext
    /// - Throws: AVError
    public func setParameters(_ codecCtx: AVCodecContext) throws {
        try throwIfFail(avcodec_parameters_from_context(stream.codecpar, codecCtx.ctxPtr))
    }
    
    /// Copy the contents of src to dst.
    ///
    /// - Parameter codecpar: AVCodecParameters
    /// - Throws: AVError
    public func copyParameters(_ codecpar: AVCodecParameters) throws {
        try throwIfFail(avcodec_parameters_copy(stream.codecpar, codecpar.parametersPtr))
    }
}
