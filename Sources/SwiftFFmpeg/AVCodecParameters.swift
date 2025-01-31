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
  var native: UnsafeMutablePointer<CAVCodecParameters>!
  var owned: Bool = false

  init(native: UnsafeMutablePointer<CAVCodecParameters>) {
    self.native = native
  }

  /// Creates a new `AVCodecParameters` and set its fields to default values (unknown/invalid/0).
  public init() {
    self.native = avcodec_parameters_alloc()
    self.owned = true
  }

  deinit {
    if owned {
      avcodec_parameters_free(&native)
    }
  }

  /// General type of the encoded data.
  public var mediaType: AVMediaType {
    get { AVMediaType(native: native.pointee.codec_type) }
    set { native.pointee.codec_type = newValue.native }
  }

  /// Specific type of the encoded data (the codec used).
  public var codecId: AVCodecID {
    get { native.pointee.codec_id }
    set { native.pointee.codec_id = newValue }
  }

  /// Additional information about the codec (corresponds to the AVI FOURCC).
  public var codecTag: UInt32 {
    get { native.pointee.codec_tag }
    set { native.pointee.codec_tag = newValue }
  }

  /// Extra binary data needed for initializing the decoder, codec-dependent.
  ///
  /// Must be allocated with `AVIO.malloc(size:)` and will be freed by
  /// `avcodec_parameters_free()`. The allocated size of extradata must be at
  /// least `extradataSize + AVConstant.inputBufferPaddingSize`, with the padding
  /// bytes zeroed.
  public var extradata: UnsafeMutablePointer<UInt8>? {
    get { native.pointee.extradata }
    set { native.pointee.extradata = newValue }
  }

  /// The size of the extradata content in bytes.
  public var extradataSize: Int {
    get { Int(native.pointee.extradata_size) }
    set { native.pointee.extradata_size = Int32(newValue) }
  }

  /// The average bitrate of the encoded data (in bits per second).
  public var bitRate: Int64 {
    get { native.pointee.bit_rate }
    set { native.pointee.bit_rate = newValue }
  }

  /// The number of bits per sample in the codedwords.
  ///
  /// This is basically the bitrate per sample. It is mandatory for a bunch of
  /// formats to actually decode them. It's the number of bits for one sample in
  /// the actual coded bitstream.
  ///
  /// This could be for example 4 for ADPCM
  /// For PCM formats this matches bits_per_raw_sample
  /// Can be 0
  public var bitsPerCodedSample: Int32 {
    get { native.pointee.bits_per_coded_sample }
    set { native.pointee.bits_per_coded_sample = newValue }
  }

  /// This is the number of valid bits in each output sample. If the
  /// sample format has more bits, the least significant bits are additional
  /// padding bits, which are always 0. Use right shifts to reduce the sample
  /// to its actual size. For example, audio formats with 24 bit samples will
  /// have bits_per_raw_sample set to 24, and format set to AV_SAMPLE_FMT_S32.
  /// To get the original sample use "(int32_t)sample >> 8"."
  ///
  /// For ADPCM this might be 12 or 16 or similar
  /// Can be 0
  public var bitsPerRawSample: Int32 {
    get { native.pointee.bits_per_raw_sample }
    set { native.pointee.bits_per_raw_sample = newValue }
  }

  /// Codec-specific bitstream restrictions that the stream conforms to.
  public var profile: Int32 {
    get { native.pointee.profile }
    set { native.pointee.profile = newValue }
  }

  public var level: Int32 {
    get { native.pointee.level }
    set { native.pointee.level = newValue }
  }

  /// Copy the contents from the supplied codec parameters.
  public func copy(from codecpar: AVCodecParameters) {
    abortIfFail(avcodec_parameters_copy(native, codecpar.native))
  }

  /// Fill the parameters struct based on the values from the supplied codec context.
  public func copy(from codecCtx: AVCodecContext) {
    abortIfFail(avcodec_parameters_from_context(native, codecCtx.native))
  }
}

// MARK: - Video

extension AVCodecParameters {
  /// The pixel format of the video frame.
  public var pixelFormat: AVPixelFormat {
    get { AVPixelFormat(native.pointee.format) }
    set { native.pointee.format = newValue.rawValue }
  }

  /// The width of the video frame in pixels.
  public var width: Int {
    get { Int(native.pointee.width) }
    set { native.pointee.width = Int32(newValue) }
  }

  /// The height of the video frame in pixels.
  public var height: Int {
    get { Int(native.pointee.height) }
    set { native.pointee.height = Int32(newValue) }
  }

  /// The aspect ratio (width / height) which a single pixel should have when displayed.
  ///
  /// When the aspect ratio is unknown / undefined, the numerator should be set to 0
  /// (the denominator may have any value).
  public var sampleAspectRatio: AVRational {
    get { native.pointee.sample_aspect_ratio }
    set { native.pointee.sample_aspect_ratio = newValue }
  }

  /// Video only. Number of frames per second, for streams with constant frame
  /// durations. Should be set to { 0, 1 } when some frames have differing
  /// durations or if the value is not known.
  ///
  /// @note This field correponds to values that are stored in codec-level
  /// headers and is typically overridden by container/transport-layer
  /// timestamps, when available. It should thus be used only as a last resort,
  /// when no higher-level timing information is available.
  public var framerate: AVRational {
    get { native.pointee.framerate }
    set { native.pointee.framerate = newValue }
  }

  /// The field order of the video frame.
  public var fieldOrder: AVFieldOrder {
    get { native.pointee.field_order }
    set { native.pointee.field_order = newValue }
  }

  /// The color range of the video frame.
  public var colorRange: AVColorRange {
    get { AVColorRange(native: native.pointee.color_range) }
    set { native.pointee.color_range = newValue.native }
  }

  /// The color primaries of the video frame.
  public var colorPrimaries: AVColorPrimaries {
    get { AVColorPrimaries(native: native.pointee.color_primaries) }
    set { native.pointee.color_primaries = newValue.native }
  }

  /// The color transfer characteristic of the video frame.
  public var colorTransferCharacteristic: AVColorTransferCharacteristic {
    get { AVColorTransferCharacteristic(native: native.pointee.color_trc) }
    set { native.pointee.color_trc = newValue.native }
  }

  /// The color space of the video frame.
  public var colorSpace: AVColorSpace {
    get { AVColorSpace(native: native.pointee.color_space) }
    set { native.pointee.color_space = newValue.native }
  }

  /// The chroma location of the video frame.
  public var chromaLocation: AVChromaLocation {
    get { AVChromaLocation(native: native.pointee.chroma_location) }
    set { native.pointee.chroma_location = newValue.native }
  }

  /// Number of delayed frames.
  public var videoDelay: Int {
    get { Int(native.pointee.video_delay) }
    set { native.pointee.video_delay = Int32(newValue) }
  }
}

// MARK: - Audio

extension AVCodecParameters {
  /// The sample format of audio.
  public var sampleFormat: AVSampleFormat {
    get { AVSampleFormat(rawValue: native.pointee.format)! }
    set { native.pointee.format = newValue.rawValue }
  }

  /// The channel layout bitmask. May be 0 if the channel layout is unknown or unspecified,
  /// otherwise the number of bits set must be equal to the channels field.
  public var channelLayout: AVChannelLayout {
    get { native.pointee.ch_layout }
    set { native.pointee.ch_layout = newValue }
  }

  /// The number of audio samples per second.
  public var sampleRate: Int {
    get { Int(native.pointee.sample_rate) }
    set { native.pointee.sample_rate = Int32(newValue) }
  }

  /// Audio frame size, if known. Required by some formats to be static.
  public var frameSize: Int {
    get { Int(native.pointee.frame_size) }
    set { native.pointee.frame_size = Int32(newValue) }
  }
}
