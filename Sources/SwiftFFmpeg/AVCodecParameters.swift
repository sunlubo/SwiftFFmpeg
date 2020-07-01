//
//  AVCodecParameters.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/26.
//

import CFFmpeg

typealias CAVCodecParameters = CFFmpeg.AVCodecParameters

/// This class describes the properties of an encoded stream.
public final class AVCodecParameters {
  let cParametersPtr: UnsafeMutablePointer<CAVCodecParameters>
  var cParameters: CAVCodecParameters { cParametersPtr.pointee }

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
    get { cParameters.codec_type }
    set { cParametersPtr.pointee.codec_type = newValue }
  }

  /// Specific type of the encoded data (the codec used).
  public var codecId: AVCodecID {
    get { cParameters.codec_id }
    set { cParametersPtr.pointee.codec_id = newValue }
  }

  /// Codec-specific bitstream restrictions that the stream conforms to.
  public var profile: Int32 {
    get { cParameters.profile }
    set { cParametersPtr.pointee.profile = newValue }
  }

  /// Additional information about the codec (corresponds to the AVI FOURCC).
  public var codecTag: UInt32 {
    get { cParameters.codec_tag }
    set { cParametersPtr.pointee.codec_tag = newValue }
  }

  /// Extra binary data needed for initializing the decoder, codec-dependent.
  ///
  /// Must be allocated with `AVIO.malloc(size:)` and will be freed by
  /// `avcodec_parameters_free()`. The allocated size of extradata must be at
  /// least `extradataSize + AVConstant.inputBufferPaddingSize`, with the padding
  /// bytes zeroed.
  public var extradata: UnsafeMutablePointer<UInt8>? {
    get { cParameters.extradata }
    set { cParametersPtr.pointee.extradata = newValue }
  }

  /// The size of the extradata content in bytes.
  public var extradataSize: Int {
    get { Int(cParameters.extradata_size) }
    set { cParametersPtr.pointee.extradata_size = Int32(newValue) }
  }

  /// The average bitrate of the encoded data (in bits per second).
  public var bitRate: Int64 {
    get { cParameters.bit_rate }
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
    get { AVPixelFormat(cParameters.format) }
    set { cParametersPtr.pointee.format = newValue.rawValue }
  }

  /// The width of the video frame in pixels.
  public var width: Int {
    get { Int(cParameters.width) }
    set { cParametersPtr.pointee.width = Int32(newValue) }
  }

  /// The height of the video frame in pixels.
  public var height: Int {
    get { Int(cParameters.height) }
    set { cParametersPtr.pointee.height = Int32(newValue) }
  }

  /// The aspect ratio (width / height) which a single pixel should have when displayed.
  ///
  /// When the aspect ratio is unknown / undefined, the numerator should be set to 0
  /// (the denominator may have any value).
  public var sampleAspectRatio: AVRational {
    get { cParameters.sample_aspect_ratio }
    set { cParametersPtr.pointee.sample_aspect_ratio = newValue }
  }

  /// Number of delayed frames.
  public var videoDelay: Int {
    get { Int(cParameters.video_delay) }
    set { cParametersPtr.pointee.video_delay = Int32(newValue) }
  }

  /// The color range of the video frame.
  public var colorRange: AVColorRange {
    get { cParameters.color_range }
    set { cParametersPtr.pointee.color_range = newValue }
  }

  /// The color primaries of the video frame.
  public var colorPrimaries: AVColorPrimaries {
    get { cParameters.color_primaries }
    set { cParametersPtr.pointee.color_primaries = newValue }
  }

  /// The color transfer characteristic of the video frame.
  public var colorTransferCharacteristic: AVColorTransferCharacteristic {
    get { cParameters.color_trc }
    set { cParametersPtr.pointee.color_trc = newValue }
  }

  /// The color space of the video frame.
  public var colorSpace: AVColorSpace {
    get { cParameters.color_space }
    set { cParametersPtr.pointee.color_space = newValue }
  }

  /// The chroma location of the video frame.
  public var chromaLocation: AVChromaLocation {
    get { cParameters.chroma_location }
    set { cParametersPtr.pointee.chroma_location = newValue }
  }
}

// MARK: - Audio

extension AVCodecParameters {

  /// The sample format of audio.
  public var sampleFormat: AVSampleFormat {
    get { AVSampleFormat(rawValue: cParameters.format)! }
    set { cParametersPtr.pointee.format = newValue.rawValue }
  }

  /// The channel layout bitmask. May be 0 if the channel layout is unknown or unspecified,
  /// otherwise the number of bits set must be equal to the channels field.
  public var channelLayout: AVChannelLayout {
    get { AVChannelLayout(rawValue: cParameters.channel_layout) }
    set { cParametersPtr.pointee.channel_layout = newValue.rawValue }
  }

  /// The number of audio channels.
  public var channelCount: Int {
    get { Int(cParameters.channels) }
    set { cParametersPtr.pointee.channels = Int32(newValue) }
  }

  /// The number of audio samples per second.
  public var sampleRate: Int {
    get { Int(cParameters.sample_rate) }
    set { cParametersPtr.pointee.sample_rate = Int32(newValue) }
  }

  /// Audio frame size, if known. Required by some formats to be static.
  public var frameSize: Int {
    get { Int(cParameters.frame_size) }
    set { cParametersPtr.pointee.frame_size = Int32(newValue) }
  }
}
