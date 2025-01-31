//
//  AVSideData.swift
//  SwiftFFmpeg
//
//  Created by Greg Cotten on 3/31/20.
//
//

import CFFmpeg

public typealias AVFrameSideDataType = CFFmpeg.AVFrameSideDataType

extension AVFrameSideDataType {

  /// The data is the AVPanScan struct defined in libavcodec.
  public static let panScan = AV_FRAME_DATA_PANSCAN

  /// ATSC A53 Part 4 Closed Captions.
  /// A53 CC bitstream is stored as uint8_t in AVFrameSideData.data.
  /// The number of bytes of CC data is AVFrameSideData.size.
  public static let a53CC = AV_FRAME_DATA_A53_CC

  /// Stereoscopic 3d metadata.
  /// The data is the AVStereo3D struct defined in libavutil/stereo3d.h.
  public static let stereo3D = AV_FRAME_DATA_STEREO3D

  /// The data is the AVMatrixEncoding enum defined in libavutil/channel_layout.h.
  public static let matrixEncoding = AV_FRAME_DATA_MATRIXENCODING

  /// Metadata relevant to a downmix procedure.
  /// The data is the AVDownmixInfo struct defined in libavutil/downmix_info.h.
  public static let downMixInfo = AV_FRAME_DATA_DOWNMIX_INFO

  /// ReplayGain information in the form of the AVReplayGain struct.
  public static let replayGain = AV_FRAME_DATA_REPLAYGAIN

  /// This side data contains a 3x3 transformation matrix describing an affine
  /// transformation that needs to be applied to the frame for correct
  /// presentation.
  /// See libavutil/display.h for a detailed description of the data.
  public static let displayMatrix = AV_FRAME_DATA_DISPLAYMATRIX

  /// Active Format Description data consisting of a single byte as specified
  /// in ETSI TS 101 154 using AVActiveFormatDescription enum.
  public static let afd = AV_FRAME_DATA_AFD

  /// Motion vectors exported by some codecs (on demand through the export_mvs
  /// flag set in the libavcodec AVCodecContext flags2 option).
  /// The data is the AVMotionVector struct defined in
  /// libavutil/motion_vector.h.
  public static let motionVectors = AV_FRAME_DATA_MOTION_VECTORS

  /// Recommmends skipping the specified number of samples. This is exported
  /// only if the "skip_manual" AVOption is set in libavcodec.
  /// This has the same format as AV_PKT_DATA_SKIP_SAMPLES.
  /// @code
  /// u32le number of samples to skip from start of this packet
  /// u32le number of samples to skip from end of this packet
  /// u8    reason for start skip
  /// u8    reason for end   skip (0=padding silence, 1=convergence)
  /// @endcode
  public static let skipSamples = AV_FRAME_DATA_SKIP_SAMPLES

  /// This side data must be associated with an audio frame and corresponds to
  /// enum AVAudioServiceType defined in avcodec.h.
  public static let audioServiceType = AV_FRAME_DATA_AUDIO_SERVICE_TYPE

  /// Mastering display metadata associated with a video frame. The payload is
  /// an AVMasteringDisplayMetadata type and contains information about the
  /// mastering display color volume.
  public static let masteringDisplayMetadata = AV_FRAME_DATA_MASTERING_DISPLAY_METADATA

  /// The GOP timecode in 25 bit timecode format. Data format is 64-bit integer.
  /// This is set on the first frame of a GOP that has a temporal reference of 0.
  public static let gopTimecode = AV_FRAME_DATA_GOP_TIMECODE

  /// The data represents the AVSphericalMapping structure defined in
  /// libavutil/spherical.h.
  public static let spherical = AV_FRAME_DATA_SPHERICAL

  /// Content light level (based on CTA-861.3). This payload contains data in
  /// the form of the AVContentLightMetadata struct.
  public static let contentLightLevel = AV_FRAME_DATA_CONTENT_LIGHT_LEVEL

  /// The data contains an ICC profile as an opaque octet buffer following the
  /// format described by ISO 15076-1 with an optional name defined in the
  /// metadata key entry "name".
  public static let iccProfile = AV_FRAME_DATA_ICC_PROFILE

  #if FF_API_FRAME_QP

  /// Implementation-specific description of the format of AV_FRAME_QP_TABLE_DATA.
  /// The contents of this side data are undocumented and internal; use
  /// av_frame_set_qp_table() and av_frame_get_qp_table() to access this in a
  /// meaningful way instead.
  public static let qpTableProperties = AV_FRAME_DATA_QP_TABLE_PROPERTIES

  /// Raw QP table data. Its format is described by
  /// AV_FRAME_DATA_QP_TABLE_PROPERTIES. Use av_frame_set_qp_table() and
  /// av_frame_get_qp_table() to access this instead.
  public static let qpTableData = AV_FRAME_DATA_QP_TABLE_DATA
  #endif

  /// Timecode which conforms to SMPTE ST 12-1. The data is an array of 4 uint32_t
  /// where the first uint32_t describes how many (1-3) of the other timecodes are used.
  /// The timecode format is described in the av_timecode_get_smpte_from_framenum()
  /// function in libavutil/timecode.c.
  public static let S12MTimecode = AV_FRAME_DATA_S12M_TIMECODE

  /// HDR dynamic metadata associated with a video frame. The payload is
  /// an AVDynamicHDRPlus type and contains information for color
  /// volume transform - application 4 of SMPTE 2094-40:2016 standard.
  public static let dynamicHDRPlus = AV_FRAME_DATA_DYNAMIC_HDR_PLUS

  /// Regions Of Interest, the data is an array of AVRegionOfInterest type, the number of
  /// array element is implied by AVFrameSideData.size / AVRegionOfInterest.self_size.
  public static let regionsOfInterest = AV_FRAME_DATA_REGIONS_OF_INTEREST

  /// Encoding parameters for a video frame, as described by AVVideoEncParams.
  public static let videoEncodingParams = AV_FRAME_DATA_VIDEO_ENC_PARAMS

  /// User data unregistered metadata associated with a video frame.
  /// This is the H.26[45] UDU SEI message, and shouldn't be used for any other purpose
  /// The data is stored as uint8_t in AVFrameSideData.data which is 16 bytes of
  /// uuid_iso_iec_11578 followed by AVFrameSideData.size - 16 bytes of user_data_payload_byte.
  public static let seiUnregistered = AV_FRAME_DATA_SEI_UNREGISTERED

  /// Film grain parameters for a frame, described by AVFilmGrainParams.
  /// Must be present for every frame which should have film grain applied.
  ///
  /// May be present multiple times, for example when there are multiple
  /// alternative parameter sets for different video signal characteristics.
  /// The user should select the most appropriate set for the application.
  public static let filmGrainParams = AV_FRAME_DATA_FILM_GRAIN_PARAMS

  /// Bounding boxes for object detection and classification,
  /// as described by AVDetectionBBoxHeader.
  public static let detectionBBoxes = AV_FRAME_DATA_DETECTION_BBOXES

  /// Dolby Vision RPU raw data, suitable for passing to x265
  /// or other libraries. Array of uint8_t, with NAL emulation
  /// bytes intact.
  public static let dolbyVisionRPU = AV_FRAME_DATA_DOVI_RPU_BUFFER

  /// Parsed Dolby Vision metadata, suitable for passing to a software
  /// implementation. The payload is the AVDOVIMetadata struct defined in
  /// libavutil/dovi_meta.h.
  public static let dolbyVisionMetadata = AV_FRAME_DATA_DOVI_METADATA

  /// HDR Vivid dynamic metadata associated with a video frame. The payload is
  /// an AVDynamicHDRVivid type and contains information for color
  /// volume transform - CUVA 005.1-2021.
  public static let dynamicHDRVivid = AV_FRAME_DATA_DYNAMIC_HDR_VIVID

  /// Ambient viewing environment metadata, as defined by H.274.
  public static let ambientViewingEnvironment = AV_FRAME_DATA_AMBIENT_VIEWING_ENVIRONMENT

  /// Provide encoder-specific hinting information about changed/unchanged
  /// portions of a frame.  It can be used to pass information about which
  /// macroblocks can be skipped because they didn't change from the
  /// corresponding ones in the previous frame. This could be useful for
  /// applications which know this information in advance to speed up
  /// encoding.
  public static let videoHint = AV_FRAME_DATA_VIDEO_HINT

  /// Raw LCEVC payload data, as a uint8_t array, with NAL emulation
  /// bytes intact.
  public static let lcevc = AV_FRAME_DATA_LCEVC

  /// This side data must be associated with a video frame.
  /// The presence of this side data indicates that the video stream is
  /// composed of multiple views (e.g. stereoscopic 3D content,
  /// cf. H.264 Annex H or H.265 Annex G).
  /// The data is an int storing the view ID.
  public static let viewId = AV_FRAME_DATA_VIEW_ID

  /// The name of the type.
  public var name: String {
    String(cString: av_frame_side_data_name(self))
  }
}

typealias CAVFrameSideData = CFFmpeg.AVFrameSideData

/// Structure to hold side data for an AVFrame.
///
/// sizeof(AVFrameSideData) is not a part of the public ABI, so new fields may be added
/// o the end with a minor bump.
public final class AVFrameSideData {
  let native: UnsafeMutablePointer<CAVFrameSideData>

  init(native: UnsafeMutablePointer<CAVFrameSideData>) {
    self.native = native
  }

  public var type: AVFrameSideDataType {
    AVFrameSideDataType(rawValue: native.pointee.type.rawValue)
  }

  public var data: UnsafeMutablePointer<UInt8> {
    native.pointee.data
  }

  public var size: Int {
    Int(native.pointee.size)
  }

  public var metadata: [String: String] {
    var dict = [String: String]()
    var tag: UnsafeMutablePointer<AVDictionaryEntry>?
    while let next = av_dict_get(native.pointee.metadata, "", tag, AV_DICT_IGNORE_SUFFIX) {
      dict[String(cString: next.pointee.key)] = String(cString: next.pointee.value)
      tag = next
    }
    return dict
  }

  public var buffer: AVBuffer {
    AVBuffer(native: native.pointee.buf)
  }
}
