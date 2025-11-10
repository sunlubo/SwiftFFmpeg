//
//  AVPacket.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVPacket

typealias CAVPacket = CFFmpeg.AVPacket

/// This structure stores compressed data. It is typically exported by demuxers
/// and then passed as input to decoders, or received as output from encoders and
/// then passed to muxers.
///
/// For video, it should typically contain one compressed frame. For audio it may
/// contain several compressed frames. Encoders are allowed to output empty packets,
/// with no compressed data, containing only side data (e.g. to update some stream
/// parameters at the end of encoding).
///
/// The semantics of data ownership depends on the `buffer` field.
/// If it is set, the packet data is dynamically allocated and is valid indefinitely
/// until a call to `unref()` reduces the reference count to 0.
///
/// If the `buffer` field is not set, `ref(from:)` would make a copy instead of increasing the reference count.
///
/// The side data is always allocated with `AVIO.malloc(size:)`, copied by `ref(from:)` and freed `unref()`.
public final class AVPacket {
  var native: UnsafeMutablePointer<CAVPacket>!

  init(native: UnsafeMutablePointer<CAVPacket>) {
    self.native = native
  }

  /// Create an `AVPacket` and set its fields to default values.
  ///
  /// - Note: This only allocates the `AVPacket` itself, not the data buffers.
  ///   Those must be allocated through other means such as `av_new_packet`.
  public init() {
    self.native = av_packet_alloc()
  }

  deinit {
    av_packet_free(&native)
  }

  /// A reference to the reference-counted buffer where the packet data is stored.
  /// May be `nil`, then the packet data is not reference-counted.
  public var buffer: AVBuffer? {
    get { native.pointee.buf.map(AVBuffer.init(native:)) }
    set { native.pointee.buf = newValue?.native }
  }

  /// Presentation timestamp in `AVStream.timebase` units; the time at which the decompressed packet
  /// will be presented to the user.
  ///
  /// Can be `AVTimestamp.noPTS` if it is not stored in the file.
  public var pts: Int64 {
    get { native.pointee.pts }
    set { native.pointee.pts = newValue }
  }

  /// Decompression timestamp in `AVStream.timebase` units; the time at which the packet is decompressed.
  ///
  /// Can be `AVTimestamp.noPTS` if it is not stored in the file.
  public var dts: Int64 {
    get { native.pointee.dts }
    set { native.pointee.dts = newValue }
  }

  public var data: UnsafeMutablePointer<UInt8>? {
    get { native.pointee.data }
    set { native.pointee.data = newValue }
  }

  public var size: Int {
    get { Int(native.pointee.size) }
    set { native.pointee.size = Int32(newValue) }
  }

  public var streamIndex: Int {
    get { Int(native.pointee.stream_index) }
    set { native.pointee.stream_index = Int32(newValue) }
  }

  public var flags: Flag {
    get { Flag(rawValue: native.pointee.flags) }
    set { native.pointee.flags = newValue.rawValue }
  }

  /// Duration of this packet in `AVStream.timebase` units, 0 if unknown.
  /// Equals `next_pts - this_pts` in presentation order.
  public var duration: Int64 {
    get { native.pointee.duration }
    set { native.pointee.duration = newValue }
  }

  /// Byte position in stream, -1 if unknown.
  public var position: Int64 {
    get { native.pointee.pos }
    set { native.pointee.pos = newValue }
  }

  /// Convert valid timing fields (timestamps / durations) in a packet from one timebase to another.
  /// Timestamps with unknown values (`AVTimestamp.noPTS`) will be ignored.
  ///
  /// - Parameters:
  ///   - src: source timebase, in which the timing fields in pkt are expressed.
  ///   - dst: destination timebase, to which the timing fields will be converted.
  public func rescaleTimestamp(from src: AVRational, to dst: AVRational) {
    av_packet_rescale_ts(native, src, dst)
  }

  /// Setup a new reference to the data described by a given packet.
  ///
  /// If `src` is reference-counted, setup this frame as a new reference to the buffer in `src`.
  /// Otherwise allocate a new buffer in this packet and copy the data from `src` into it.
  ///
  /// All the other fields are copied from `src`.
  ///
  /// - Parameter src: the source packet
  /// - Throws: AVerror
  public func ref(from src: AVPacket) throws {
    try throwIfFail(av_packet_ref(native, src.native))
  }

  /// Wipe the packet.
  ///
  /// Unreference the buffer referenced by the packet and reset the remaining packet fields
  /// to their default values.
  public func unref() {
    av_packet_unref(native)
  }

  /// Move every field in `src` to this packet and reset `src`.
  ///
  /// - Parameter src: the source packet
  public func moveRef(from src: AVPacket) {
    av_packet_move_ref(native, src.native)
  }

  /// Create a new packet that references the same data as this packet.
  ///
  /// This is a shortcut for `init() + ref(from:)`.
  ///
  /// - Returns: newly created `AVPacket` on success, `nil` on error.
  public func clone() -> AVPacket? {
    av_packet_clone(native).map(AVPacket.init(native:))
  }

  /// Create a writable reference for the data described by a given packet,
  /// avoiding data copy if possible.
  ///
  /// - Throws: AVError
  public func makeWritable() throws {
    try throwIfFail(av_packet_make_writable(native))
  }
}

// MARK: - AVPacket.Flag

extension AVPacket {
  public struct Flag: OptionSet {
    /// The packet contains a keyframe.
    public static let key = Flag(rawValue: AV_PKT_FLAG_KEY)
    /// The packet content is corrupted.
    public static let corrupt = Flag(rawValue: AV_PKT_FLAG_CORRUPT)
    /// Flag is used to discard packets which are required to maintain valid decoder state
    /// but are not required for output and should be dropped after decoding.
    public static let discard = Flag(rawValue: AV_PKT_FLAG_DISCARD)
    /// The packet comes from a trusted source.
    ///
    /// Otherwise-unsafe constructs such as arbitrary pointers to data outside the packet may be followed.
    public static let trusted = Flag(rawValue: AV_PKT_FLAG_TRUSTED)
    /// Flag is used to indicate packets that contain frames that can be discarded by the decoder.
    /// I.e. Non-reference frames.
    public static let disposable = Flag(rawValue: AV_PKT_FLAG_DISPOSABLE)

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
  }
}

extension AVPacket.Flag: CustomStringConvertible {
  public var description: String {
    var str = "["
    if contains(.key) { str += "key, " }
    if contains(.corrupt) { str += "corrupt, " }
    if contains(.discard) { str += "discard, " }
    if contains(.trusted) { str += "trusted, " }
    if contains(.disposable) { str += "disposable, " }
    if str.suffix(2) == ", " {
      str.removeLast(2)
    }
    str += "]"
    return str
  }
}

// MARK: - AVPacketSideDataType

public enum AVPacketSideDataType: UInt32 {
  /// An AV_PKT_DATA_PALETTE side data packet contains exactly AVPALETTE_SIZE
  /// bytes worth of palette. This side data signals that a new palette is present.
  case palette

  /// The AV_PKT_DATA_NEW_EXTRADATA is used to notify the codec or the format
  /// that the extradata buffer was changed and the receiving side should
  /// act upon it appropriately. The new extradata is embedded in the side
  /// data buffer and should be immediately used for processing the current
  /// frame or packet.
  case newExtradata

  /// An AV_PKT_DATA_PARAM_CHANGE side data packet. See avcodec.h for layout.
  case paramChange

  /// An AV_PKT_DATA_H263_MB_INFO side data packet contains a number of
  /// structures with info about macroblocks relevant to splitting the
  /// packet into smaller packets on macroblock edges (e.g. as for RFC 2190).
  /// That is, it does not necessarily contain info about all macroblocks,
  /// as long as the distance between macroblocks in the info is smaller
  /// than the target payload size.
  /// Each MB info structure is 12 bytes. See avcodec.h for layout.
  case h263MbInfo

  /// This side data should be associated with an audio stream and contains
  /// ReplayGain information in form of the AVReplayGain struct.
  case replayGain

  /// This side data contains a 3x3 transformation matrix describing an affine
  /// transformation that needs to be applied to the decoded video frames for
  /// correct presentation.
  case displaymatrix

  /// This side data should be associated with a video stream and contains
  /// Stereoscopic 3D information in form of the AVStereo3D struct.
  case stereo3d

  /// This side data should be associated with an audio stream and corresponds
  /// to enum AVAudioServiceType.
  case audioServiceType

  /// This side data contains quality related information from the encoder.
  /// See avcodec.h for layout.
  case qualityStats

  /// This side data contains an integer value representing the stream index
  /// of a "fallback" track.  A fallback track indicates an alternate
  /// track to use when the current track can not be decoded for some reason.
  /// e.g. no decoder available for codec.
  case fallbackTrack

  /// This side data corresponds to the AVCPBProperties struct.
  case cpbProperties

  /// Recommmends skipping the specified number of samples
  /// See avcodec.h for layout.
  case skipSamples

  /// An AV_PKT_DATA_JP_DUALMONO side data packet indicates that
  /// the packet may contain "dual mono" audio specific to Japanese DTV
  /// and if it is true, recommends only the selected channel to be used.
  /// See avcodec.h for layout.
  case jpDualmono

  /// A list of zero terminated key/value strings. There is no end marker for
  /// the list, so it is required to rely on the side data size to stop.
  case stringsMetadata

  /// Subtitle event position
  /// See avcodec.h for layout.
  case subtitlePosition

  /// Data found in BlockAdditional element of matroska container. There is
  /// no end marker for the data, so it is required to rely on the side data
  /// size to recognize the end. 8 byte id (as found in BlockAddId) followed
  /// by data.
  case matroskaBlockadditional

  /// The optional first identifier line of a WebVTT cue.
  case webvttIdentifiers

  /// The optional settings (rendering instructions) that immediately
  /// follow the timestamp specifier of a WebVTT cue.
  case webvttSettings

  /// A list of zero terminated key/value strings. There is no end marker for
  /// the list, so it is required to rely on the side data size to stop. This
  /// side data includes updated metadata which appeared in the stream.
  case metadataUpdate

  /// MPEGTS stream ID as uint8_t, this is required to pass the stream ID
  /// information from the demuxer to the corresponding muxer.
  case mpegtsStreamId

  /// Mastering display metadata (based on SMPTE-2086:2014). This metadata
  /// should be associated with a video stream and contains data in the form
  /// of the AVMasteringDisplayMetadata struct.
  case masteringDisplayMetadata

  /// This side data should be associated with a video stream and corresponds
  /// to the AVSphericalMapping structure.
  case spherical

  /// Content light level (based on CTA-861.3). This metadata should be
  /// associated with a video stream and contains data in the form of the
  /// AVContentLightMetadata struct.
  case contentLightLevel

  /// ATSC A53 Part 4 Closed Captions. This metadata should be associated with
  /// a video stream. A53 CC bitstream is stored as uint8_t in AVPacketSideData.data.
  /// The number of bytes of CC data is AVPacketSideData.size.
  case a53Cc

  /// This side data is encryption initialization data.
  /// The format is not part of ABI, use av_encryption_init_info_* methods to
  /// access.
  case encryptionInitInfo

  /// This side data contains encryption info for how to decrypt the packet.
  /// The format is not part of ABI, use av_encryption_info_* methods to access.
  case encryptionInfo

  /// Active Format Description data consisting of a single byte as specified
  /// in ETSI TS 101 154 using AVActiveFormatDescription enum.
  case afd

  /// Producer Reference Time data corresponding to the AVProducerReferenceTime struct,
  /// usually exported by some encoders (on demand through the prft flag set in the
  /// AVCodecContext export_side_data field).
  case prft

  /// ICC profile data consisting of an opaque octet buffer following the
  /// format described by ISO 15076-1.
  case iccProfile

  /// DOVI configuration
  /// ref:
  /// dolby-vision-bitstreams-within-the-iso-base-media-file-format-v2.1.2, section 2.2
  /// dolby-vision-bitstreams-in-mpeg-2-transport-stream-multiplex-v1.2, section 3.3
  /// Tags are stored in struct AVDOVIDecoderConfigurationRecord.
  case doviConfig

  /// Timecode which conforms to SMPTE ST 12-1:2014. The data is an array of 4 uint32_t
  /// where the first uint32_t describes how many (1-3) of the other timecodes are used.
  /// The timecode format is described in the documentation of av_timecode_get_smpte_from_framenum()
  /// function in libavutil/timecode.h.
  case s12mTimecode

  /// HDR10+ dynamic metadata associated with a video frame. The metadata is in
  /// the form of the AVDynamicHDRPlus struct and contains
  /// information for color volume transform - application 4 of
  /// SMPTE 2094-40:2016 standard.
  case dynamicHDR10Plus

  /// IAMF Mix Gain Parameter Data associated with the audio frame. This metadata
  /// is in the form of the AVIAMFParamDefinition struct and contains information
  /// defined in sections 3.6.1 and 3.8.1 of the Immersive Audio Model and
  /// Formats standard.
  case iamfMixGainParam

  /// IAMF Demixing Info Parameter Data associated with the audio frame. This
  /// metadata is in the form of the AVIAMFParamDefinition struct and contains
  /// information defined in sections 3.6.1 and 3.8.2 of the Immersive Audio Model
  /// and Formats standard.
  case iamfDemixingInfoParam

  /// IAMF Recon Gain Info Parameter Data associated with the audio frame. This
  /// metadata is in the form of the AVIAMFParamDefinition struct and contains
  /// information defined in sections 3.6.1 and 3.8.3 of the Immersive Audio Model
  /// and Formats standard.
  case iamfReconGainInfoParam

  /// Ambient viewing environment metadata, as defined by H.274. This metadata
  /// should be associated with a video stream and contains data in the form
  /// of the AVAmbientViewingEnvironment struct.
  case ambientViewingEnvironment

  /// The number of pixels to discard from the top/bottom/left/right border of the
  /// decoded frame to obtain the sub-rectangle intended for presentation.
  ///
  /// @code
  /// u32le crop_top
  /// u32le crop_bottom
  /// u32le crop_left
  /// u32le crop_right
  /// @endcode
  case frameCropping

  /// Raw LCEVC payload data, as a uint8_t array, with NAL emulation
  /// bytes intact.
  case lcevc

  var native: CFFmpeg.AVPacketSideDataType {
    CFFmpeg.AVPacketSideDataType(rawValue)
  }

  init(native: CFFmpeg.AVPacketSideDataType) {
    guard let type = AVPacketSideDataType(rawValue: native.rawValue) else {
      fatalError("Unknown packet side data type: \(native)")
    }
    self = type
  }
}
