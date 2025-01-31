//
//  Codec.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/28.
//

import CFFmpeg

// MARK: - AVCodecID

public typealias AVCodecID = CFFmpeg.AVCodecID

extension AVCodecID {
  public static let none = AV_CODEC_ID_NONE

  // MARK: - Video Codecs

  public static let MPEG1VIDEO = AV_CODEC_ID_MPEG1VIDEO
  /// preferred ID for MPEG-1/2 video decoding
  public static let MPEG2VIDEO = AV_CODEC_ID_MPEG2VIDEO
  public static let H261 = AV_CODEC_ID_H261
  public static let H263 = AV_CODEC_ID_H263
  public static let MPEG4 = AV_CODEC_ID_MPEG4
  public static let H264 = AV_CODEC_ID_H264
  public static let VP3 = AV_CODEC_ID_VP3
  public static let PNG = AV_CODEC_ID_PNG
  public static let PGM = AV_CODEC_ID_PGM
  public static let BMP = AV_CODEC_ID_BMP
  public static let JPEG2000 = AV_CODEC_ID_JPEG2000
  public static let VP5 = AV_CODEC_ID_VP5
  public static let VP6 = AV_CODEC_ID_VP6
  public static let TIFF = AV_CODEC_ID_TIFF
  public static let GIF = AV_CODEC_ID_GIF
  public static let VP8 = AV_CODEC_ID_VP8
  public static let VP9 = AV_CODEC_ID_VP9
  public static let WEBP = AV_CODEC_ID_WEBP
  public static let HEVC = AV_CODEC_ID_HEVC
  public static let VP7 = AV_CODEC_ID_VP7
  public static let APNG = AV_CODEC_ID_APNG
  public static let AV1 = AV_CODEC_ID_AV1
  public static let SVG = AV_CODEC_ID_SVG

  // MARK: - various PCM "codecs"

  /// A dummy id pointing at the start of audio codecs
  public static let FIRST_AUDIO = AV_CODEC_ID_FIRST_AUDIO
  public static let PCM_S16LE = AV_CODEC_ID_PCM_S16LE
  public static let PCM_S16BE = AV_CODEC_ID_PCM_S16BE
  public static let PCM_U16LE = AV_CODEC_ID_PCM_U16LE
  public static let PCM_U16BE = AV_CODEC_ID_PCM_U16BE
  public static let PCM_S8 = AV_CODEC_ID_PCM_S8
  public static let PCM_U8 = AV_CODEC_ID_PCM_U8
  public static let PCM_MULAW = AV_CODEC_ID_PCM_MULAW
  public static let PCM_ALAW = AV_CODEC_ID_PCM_ALAW
  public static let PCM_S32LE = AV_CODEC_ID_PCM_S32LE
  public static let PCM_S32BE = AV_CODEC_ID_PCM_S32BE
  public static let PCM_U32LE = AV_CODEC_ID_PCM_U32LE
  public static let PCM_U32BE = AV_CODEC_ID_PCM_U32BE
  public static let PCM_S24LE = AV_CODEC_ID_PCM_S24LE
  public static let PCM_S24BE = AV_CODEC_ID_PCM_S24BE
  public static let PCM_U24LE = AV_CODEC_ID_PCM_U24LE
  public static let PCM_U24BE = AV_CODEC_ID_PCM_U24BE
  public static let PCM_S24DAUD = AV_CODEC_ID_PCM_S24DAUD
  public static let PCM_ZORK = AV_CODEC_ID_PCM_ZORK
  public static let PCM_S16LE_PLANAR = AV_CODEC_ID_PCM_S16LE_PLANAR
  public static let PCM_DVD = AV_CODEC_ID_PCM_DVD
  public static let PCM_F32BE = AV_CODEC_ID_PCM_F32BE
  public static let PCM_F32LE = AV_CODEC_ID_PCM_F32LE
  public static let PCM_F64BE = AV_CODEC_ID_PCM_F64BE
  public static let PCM_F64LE = AV_CODEC_ID_PCM_F64LE
  public static let PCM_BLURAY = AV_CODEC_ID_PCM_BLURAY
  public static let PCM_LXF = AV_CODEC_ID_PCM_LXF
  public static let S302M = AV_CODEC_ID_S302M
  public static let PCM_S8_PLANAR = AV_CODEC_ID_PCM_S8_PLANAR
  public static let PCM_S24LE_PLANAR = AV_CODEC_ID_PCM_S24LE_PLANAR
  public static let PCM_S32LE_PLANAR = AV_CODEC_ID_PCM_S32LE_PLANAR
  public static let PCM_S16BE_PLANAR = AV_CODEC_ID_PCM_S16BE_PLANAR

  public static let PCM_S64LE = AV_CODEC_ID_PCM_S64LE
  public static let PCM_S64BE = AV_CODEC_ID_PCM_S64BE
  public static let PCM_F16LE = AV_CODEC_ID_PCM_F16LE
  public static let PCM_F24LE = AV_CODEC_ID_PCM_F24LE

  // MARK: - AMR

  public static let AMR_NB = AV_CODEC_ID_AMR_NB
  public static let AMR_WB = AV_CODEC_ID_AMR_WB

  // MARK: - Audio Codecs

  public static let MP2 = AV_CODEC_ID_MP2
  /// preferred ID for decoding MPEG audio layer 1, 2 or 3
  public static let MP3 = AV_CODEC_ID_MP3
  public static let AAC = AV_CODEC_ID_AAC
  public static let FLAC = AV_CODEC_ID_FLAC
  public static let APE = AV_CODEC_ID_APE
  public static let MP1 = AV_CODEC_ID_MP1

  /// The name of the codec.
  public var name: String {
    String(cString: avcodec_get_name(self))
  }

  /// The media type of the codec.
  public var mediaType: AVMediaType {
    AVMediaType(native: avcodec_get_type(self))
  }
}

extension AVCodecID: @retroactive CustomStringConvertible {
  public var description: String {
    name
  }
}

// MARK: - AVCodec

typealias CAVCodec = CFFmpeg.AVCodec

public struct AVCodec {
  var native: UnsafePointer<CAVCodec>

  /// Find a registered decoder with a matching codec ID.
  ///
  /// - Parameter codecId: id of the requested decoder
  /// - Returns: A decoder if one was found, `nil` otherwise.
  public static func findDecoderById(_ codecId: AVCodecID) -> AVCodec? {
    guard let ptr = avcodec_find_decoder(codecId) else {
      return nil
    }
    return AVCodec(native: ptr)
  }

  /// Find a registered decoder with the specified name.
  ///
  /// - Parameter name: name of the requested decoder
  /// - Returns: A decoder if one was found, `nil` otherwise.
  public static func findDecoderByName(_ name: String) -> AVCodec? {
    guard let ptr = avcodec_find_decoder_by_name(name) else {
      return nil
    }
    return AVCodec(native: ptr)
  }

  /// Find a registered encoder with a matching codec ID.
  ///
  /// - Parameter codecId: id of the requested encoder
  /// - Returns: An encoder if one was found, `nil` otherwise.
  public static func findEncoderById(_ codecId: AVCodecID) -> AVCodec? {
    guard let ptr = avcodec_find_encoder(codecId) else {
      return nil
    }
    return AVCodec(native: ptr)
  }

  /// Find a registered encoder with the specified name.
  ///
  /// - Parameter name: name of the requested encoder
  /// - Returns: An encoder if one was found, `nil` otherwise.
  public static func findEncoderByName(_ name: String) -> AVCodec? {
    guard let native = avcodec_find_encoder_by_name(name) else {
      return nil
    }
    return AVCodec(native: native)
  }

  /// Returns a name for the specified profile, if available.
  ///
  /// Unlike the member function `getProfileName(...)`, which searches a list of profiles supported by a specific decoder or encoder implementation, this class function searches the list of profiles from the `codecID`'s `AVCodecDescriptor`
  public static func profileName(codecID: AVCodecID, profile: Int32) -> String? {
    String(cString: avcodec_profile_name(codecID, profile))
  }

  init(native: UnsafePointer<CAVCodec>) {
    self.native = native
  }

  /// The codec's name.
  public var name: String {
    String(cString: native.pointee.name)
  }

  /// The codec's descriptive name, meant to be more human readable than name.
  public var longName: String {
    String(cString: native.pointee.long_name)
  }

  /// The codec's media type.
  public var mediaType: AVMediaType {
    AVMediaType(native: native.pointee.type)
  }

  /// The codec's id.
  public var id: AVCodecID {
    native.pointee.id
  }

  /// The codec's capabilities.
  public var capabilities: AVCodec.Cap {
    Cap(rawValue: UInt32(native.pointee.capabilities))
  }

  /// Returns an array of the framerates supported by the codec.
  public var supportedFramerates: [AVRational]? {
    var configs: UnsafeRawPointer?
    var count: Int32 = 0
    avcodec_get_supported_config(nil, native, AV_CODEC_CONFIG_FRAME_RATE, 0, &configs, &count)
    return configs?.withMemoryRebound(to: AVRational.self, capacity: Int(count), { ptr in
      Array(UnsafeBufferPointer(start: ptr, count: Int(count)))
    })
  }

  /// Returns an array of the pixel formats supported by the codec.
  public var supportedPixelFormats: [AVPixelFormat]? {
    var configs: UnsafeRawPointer?
    var count: Int32 = 0
    avcodec_get_supported_config(nil, native, AV_CODEC_CONFIG_PIX_FORMAT, 0, &configs, &count)
    return configs?.withMemoryRebound(to: AVPixelFormat.self, capacity: Int(count), { ptr in
      Array(UnsafeBufferPointer(start: ptr, count: Int(count)))
    })
  }

  /// Returns an array of the audio samplerates supported by the codec.
  public var supportedSampleRates: [Int]? {
    var configs: UnsafeRawPointer?
    var count: Int32 = 0
    avcodec_get_supported_config(nil, native, AV_CODEC_CONFIG_SAMPLE_RATE, 0, &configs, &count)
    return configs?.withMemoryRebound(to: Int32.self, capacity: Int(count), { ptr in
      Array(UnsafeBufferPointer(start: ptr, count: Int(count))).map(Int.init(_:))
    })
  }

  /// Returns an array of the sample formats supported by the codec.
  public var supportedSampleFormats: [AVSampleFormat]? {
    var configs: UnsafeRawPointer?
    var count: Int32 = 0
    avcodec_get_supported_config(nil, native, AV_CODEC_CONFIG_SAMPLE_FORMAT, 0, &configs, &count)
    return configs?.withMemoryRebound(to: Int32.self, capacity: Int(count), { ptr in
      Array(UnsafeBufferPointer(start: ptr, count: Int(count))).compactMap(AVSampleFormat.init(rawValue:))
    })
  }

  /// Returns an array of the channel layouts supported by the codec.
  public var supportedChannelLayouts: [AVChannelLayout]? {
    var configs: UnsafeRawPointer?
    var count: Int32 = 0
    avcodec_get_supported_config(nil, native, AV_CODEC_CONFIG_CHANNEL_LAYOUT, 0, &configs, &count)
    return configs?.withMemoryRebound(to: AVChannelLayout.self, capacity: Int(count), { ptr in
      Array(UnsafeBufferPointer(start: ptr, count: Int(count)))
    })
  }

  /// Maximum value for lowres supported by the decoder.
  public var maxLowres: UInt8 {
    native.pointee.max_lowres
  }

  /// A Boolean value indicating whether the codec is decoder.
  public var isDecoder: Bool {
    av_codec_is_decoder(native) != 0
  }

  /// A Boolean value indicating whether the codec is encoder.
  public var isEncoder: Bool {
    av_codec_is_encoder(native) != 0
  }

  /// Retrieve supported hardware configurations for a codec.
  ///
  /// Values of index from zero to some maximum return the indexed configuration descriptor;
  /// all other values return `nil`.
  /// If the codec does not support any hardware configurations then it will always return `nil`.
  public func hwConfig(at index: Int) -> AVCodecHWConfig? {
    avcodec_get_hw_config(native, Int32(index)).map(AVCodecHWConfig.init(native:))
  }

  /// Returns a name for the specified profile, if available.
  public func profileName(profile: Int32) -> String? {
    String(cString: av_get_profile_name(native, profile))
  }

  /// Get all registered codecs.
  public static var supportedCodecs: [AVCodec] {
    var list = [AVCodec]()
    var state: UnsafeMutableRawPointer?
    while let ptr = av_codec_iterate(&state) {
      list.append(AVCodec(native: ptr.mutable))
    }
    return list
  }
}

// MARK: - AVCodec.Cap

extension AVCodec {
  /// Codec capabilities
  public struct Cap: OptionSet {
    /// Decoder can use draw_horiz_band callback.
    public static let drawHorizBand = Cap(rawValue: UInt32(AV_CODEC_CAP_DRAW_HORIZ_BAND))
    /// Codec uses get_buffer() for allocating buffers and supports custom allocators.
    /// If not set, it might not use get_buffer() at all or use operations that
    /// assume the buffer was allocated by avcodec_default_get_buffer.
    public static let dr1 = Cap(rawValue: UInt32(AV_CODEC_CAP_DR1))
    /// Encoder or decoder requires flushing with NULL input at the end in order to
    /// give the complete and correct output.
    ///
    /// - Note: If this flag is not set, the codec is guaranteed to never be fed with
    ///       with NULL data. The user can still send NULL data to the public encode
    ///       or decode function, but libavcodec will not pass it along to the codec
    ///       unless this flag is set.
    ///
    /// Decoders:
    /// The decoder has a non-zero delay and needs to be fed with avpkt->data=NULL,
    /// avpkt->size=0 at the end to get the delayed data until the decoder no longer
    /// returns frames.
    ///
    /// Encoders:
    /// The encoder needs to be fed with NULL data at the end of encoding until the
    /// encoder no longer returns data.
    ///
    /// - Note: For encoders implementing the AVCodec.encode2() function, setting this
    ///       flag also means that the encoder must set the pts and duration for
    ///       each output packet. If this flag is not set, the pts and duration will
    ///       be determined by libavcodec from the input frame.
    public static let delay = Cap(rawValue: UInt32(AV_CODEC_CAP_DELAY))
    /// Codec can be fed a final frame with a smaller size.
    /// This can be used to prevent truncation of the last audio samples.
    public static let smallLastFrame = Cap(rawValue: UInt32(AV_CODEC_CAP_SMALL_LAST_FRAME))
    /// Codec can output multiple frames per `AVPacket`.
    /// Normally demuxers return one frame at a time, demuxers which do not do
    /// are connected to a parser to split what they return into proper frames.
    /// This flag is reserved to the very rare category of codecs which have a
    /// bitstream that cannot be split into frames without timeconsuming
    /// operations like full decoding. Demuxers carrying such bitstreams thus
    /// may return multiple frames in a packet. This has many disadvantages like
    /// prohibiting stream copy in many cases thus it should only be considered
    /// as a last resort.
    public static let subframes = Cap(rawValue: UInt32(AV_CODEC_CAP_SUBFRAMES))
    /// Codec is experimental and is thus avoided in favor of non experimental encoders.
    public static let experimental = Cap(rawValue: UInt32(AV_CODEC_CAP_EXPERIMENTAL))
    /// Codec should fill in channel configuration and samplerate instead of container.
    public static let channelConf = Cap(rawValue: UInt32(AV_CODEC_CAP_CHANNEL_CONF))
    /// Codec supports frame-level multithreading.
    public static let frameThreads = Cap(rawValue: UInt32(AV_CODEC_CAP_FRAME_THREADS))
    /// Codec supports slice-based (or partition-based) multithreading.
    public static let sliceThreads = Cap(rawValue: UInt32(AV_CODEC_CAP_SLICE_THREADS))
    /// Codec supports changed parameters at any point.
    public static let paramChange = Cap(rawValue: UInt32(AV_CODEC_CAP_PARAM_CHANGE))
    /// Codec supports avctx->thread_count == 0 (auto).
    public static let otherThreads = Cap(rawValue: UInt32(AV_CODEC_CAP_OTHER_THREADS))
    /// Audio encoder supports receiving a different number of samples in each call.
    public static let variableFrameSize = Cap(rawValue: UInt32(AV_CODEC_CAP_VARIABLE_FRAME_SIZE))
    /// Decoder is not a preferred choice for probing.
    /// This indicates that the decoder is not a good choice for probing.
    /// It could for example be an expensive to spin up hardware decoder,
    /// or it could simply not provide a lot of useful information about
    /// the stream.
    /// A decoder marked with this flag should only be used as last resort
    /// choice for probing.
    public static let avoidProbing = Cap(rawValue: UInt32(AV_CODEC_CAP_AVOID_PROBING))
    /// Codec is backed by a hardware implementation. Typically used to identify a non-hwaccel hardware decoder.
    /// For information about hwaccels, use `hwConfig(at:)` instead.
    public static let hardware = Cap(rawValue: UInt32(AV_CODEC_CAP_HARDWARE))
    /// Codec is potentially backed by a hardware implementation, but not necessarily.
    /// This is used instead of `Cap.hardware`, if the implementation provides some sort of internal fallback.
    public static let hybrid = Cap(rawValue: UInt32(AV_CODEC_CAP_HYBRID))
    /// This codec takes the reordered_opaque field from input AVFrames
    /// and returns it in the corresponding field in `AVCodecContext` after encoding.
    public static let encoderReorderedOpaque = Cap(rawValue: 1 << 20)

    public let rawValue: UInt32

    public init(rawValue: UInt32) { self.rawValue = rawValue }
  }
}

extension AVCodec.Cap: CustomStringConvertible {
  public var description: String {
    var str = "["
    if contains(.drawHorizBand) { str += "drawHorizBand, " }
    if contains(.dr1) { str += "dr1, " }
    if contains(.delay) { str += "delay, " }
    if contains(.smallLastFrame) { str += "smallLastFrame, " }
    if contains(.subframes) { str += "subframes, " }
    if contains(.experimental) { str += "experimental, " }
    if contains(.channelConf) { str += "channelConf, " }
    if contains(.frameThreads) { str += "frameThreads, " }
    if contains(.sliceThreads) { str += "sliceThreads, " }
    if contains(.paramChange) { str += "paramChange, " }
    if contains(.otherThreads) { str += "otherThreads, " }
    if contains(.variableFrameSize) { str += "variableFrameSize, " }
    if contains(.avoidProbing) { str += "avoidProbing, " }
    if contains(.hardware) { str += "hardware, " }
    if contains(.hybrid) { str += "hybrid, " }
    if contains(.encoderReorderedOpaque) { str += "encoderReorderedOpaque, " }
    if str.suffix(2) == ", " {
      str.removeLast(2)
    }
    str += "]"
    return str
  }
}

extension AVCodec: AVOptionSupport {

  public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
    var tmp = native.pointee.priv_class
    return try withUnsafeMutablePointer(to: &tmp) { ptr in
      try body(ptr)
    }
  }
}
