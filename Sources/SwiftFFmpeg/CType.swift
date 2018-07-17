//
//  CType.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/4.
//

import CFFmpeg

/// Undefined timestamp value
///
/// Usually reported by demuxer that work on containers that do not provide
/// either pts or dts.
public let AV_NOPTS_VALUE = swift_AV_NOPTS_VALUE

public let AV_INPUT_BUFFER_PADDING_SIZE = Int(CFFmpeg.AV_INPUT_BUFFER_PADDING_SIZE)

public let AV_TS_MAX_STRING_SIZE = Int(CFFmpeg.AV_TS_MAX_STRING_SIZE)

public let AV_ERROR_MAX_STRING_SIZE = Int(CFFmpeg.AV_ERROR_MAX_STRING_SIZE)

// MARK: - AVRational

/// Rational number (pair of numerator and denominator).
public typealias AVRational = CFFmpeg.AVRational

extension AVRational {
    public static let zero = AVRational(num: 0, den: 0)
}

extension AVRational: Equatable {
    public static func == (lhs: AVRational, rhs: AVRational) -> Bool {
        return av_cmp_q(lhs, rhs) == 0
    }
}

// MARK: - AVMediaType

public typealias CAVMediaType = CFFmpeg.AVMediaType

/// Media Type
extension AVMediaType: CustomStringConvertible {
    /// Usually treated as `data`
    public static let unknown = AVMEDIA_TYPE_UNKNOWN
    public static let video = AVMEDIA_TYPE_VIDEO
    public static let audio = AVMEDIA_TYPE_AUDIO
    /// Opaque data information usually continuous
    public static let data = AVMEDIA_TYPE_DATA
    public static let subtitle = AVMEDIA_TYPE_SUBTITLE
    /// Opaque data information usually sparse
    public static let attachment = AVMEDIA_TYPE_ATTACHMENT
    public static let nb = AVMEDIA_TYPE_NB

    public var description: String {
        if let strBytes = av_get_media_type_string(self) {
            return String(cString: strBytes)
        }
        return "unknown"
    }
}

// MARK: - AVPictureType

public typealias AVPictureType = CFFmpeg.AVPictureType

/// AVPicture types, pixel formats and basic image planes manipulation.
extension AVPictureType: CustomStringConvertible {
    /// Undefined
    public static let none = AV_PICTURE_TYPE_NONE
    /// Intra
    public static let I = AV_PICTURE_TYPE_I
    /// Predicted
    public static let P = AV_PICTURE_TYPE_P
    /// Bi-dir predicted
    public static let B = AV_PICTURE_TYPE_B
    /// S(GMC)-VOP MPEG-4
    public static let S = AV_PICTURE_TYPE_S
    /// Switching Intra
    public static let SI = AV_PICTURE_TYPE_SI
    /// Switching Predicted
    public static let SP = AV_PICTURE_TYPE_SP
    /// BI type
    public static let BI = AV_PICTURE_TYPE_BI

    public var description: String {
        let char = av_get_picture_type_char(self)
        let scalar = Unicode.Scalar(Int(char))!
        return String(Character(scalar))
    }
}

// MARK: - AVPixelFormat

public typealias AVPixelFormat = CFFmpeg.AVPixelFormat

/// Pixel format.
extension AVPixelFormat {
    public static let none = AV_PIX_FMT_NONE
    /// planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
    public static let YUV420P = AV_PIX_FMT_YUV420P
    /// packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
    public static let YUYV422 = AV_PIX_FMT_YUYV422
    /// packed RGB 8:8:8, 24bpp, RGBRGB...
    public static let RGB24 = AV_PIX_FMT_RGB24
    /// packed RGB 8:8:8, 24bpp, BGRBGR...
    public static let BGR24 = AV_PIX_FMT_BGR24
    /// planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    public static let YUV422P = AV_PIX_FMT_YUV422P
    /// planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
    public static let YUV444P = AV_PIX_FMT_YUV444P
    /// planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
    public static let YUV410P = AV_PIX_FMT_YUV410P
    /// planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
    public static let YUV411P = AV_PIX_FMT_YUV411P
    ///        Y        ,  8bpp
    public static let GRAY8 = AV_PIX_FMT_GRAY8
    ///        Y        ,  1bpp, 0 is white, 1 is black, in each byte pixels are ordered from the msb to the lsb
    public static let MONOWHITE = AV_PIX_FMT_MONOWHITE
    /// Y        ,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
    public static let MONOBLACK = AV_PIX_FMT_MONOBLACK
    /// 8 bits with AV_PIX_FMT_RGB32 palette
    public static let PAL8 = AV_PIX_FMT_PAL8
    /// planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV420P and setting color_range
    public static let YUVJ420P = AV_PIX_FMT_YUVJ420P
    /// planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV422P and setting color_range
    public static let YUVJ422P = AV_PIX_FMT_YUVJ422P
    /// planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV444P and setting color_range
    public static let YUVJ444P = AV_PIX_FMT_YUVJ444P
    /// packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
    public static let UYVY422 = AV_PIX_FMT_UYVY422
    /// packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
    public static let UYYVYY411 = AV_PIX_FMT_UYYVYY411
    /// packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
    public static let BGR8 = AV_PIX_FMT_BGR8
    /// packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
    public static let BGR4 = AV_PIX_FMT_BGR4
    /// packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
    public static let BGR4_BYTE = AV_PIX_FMT_BGR4_BYTE
    /// packed RGB 3:3:2,  8bpp, (msb)2R 3G 3B(lsb)
    public static let RGB8 = AV_PIX_FMT_RGB8
    /// packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
    public static let RGB4 = AV_PIX_FMT_RGB4
    /// packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
    public static let RGB4_BYTE = AV_PIX_FMT_RGB4_BYTE
    /// planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
    public static let NV12 = AV_PIX_FMT_NV12
    /// as above, but U and V bytes are swapped
    public static let NV21 = AV_PIX_FMT_NV21

    /// packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
    public static let ARGB = AV_PIX_FMT_ARGB
    /// packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
    public static let RGBA = AV_PIX_FMT_RGBA
    /// packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
    public static let ABGR = AV_PIX_FMT_ABGR
    /// packed BGRA 8:8:8:8, 32bpp, BGRABGRA...
    public static let BGRA = AV_PIX_FMT_BGRA

    ///        Y        , 16bpp, big-endian
    public static let GRAY16BE = AV_PIX_FMT_GRAY16BE
    ///        Y        , 16bpp, little-endian
    public static let GRAY16LE = AV_PIX_FMT_GRAY16LE
    /// planar YUV 4:4:0 (1 Cr & Cb sample per 1x2 Y samples)
    public static let YUV440P = AV_PIX_FMT_YUV440P
    /// planar YUV 4:4:0 full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV440P and setting color_range
    public static let YUVJ440P = AV_PIX_FMT_YUVJ440P
    /// planar YUV 4:2:0, 20bpp, (1 Cr & Cb sample per 2x2 Y & A samples)
    public static let YUVA420P = AV_PIX_FMT_YUVA420P
    /// packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as big-endian
    public static let RGB48BE = AV_PIX_FMT_RGB48BE
    /// packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as little-endian
    public static let RGB48LE = AV_PIX_FMT_RGB48LE

    /// packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), big-endian
    public static let RGB565BE = AV_PIX_FMT_RGB565BE
    /// packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), little-endian
    public static let RGB565LE = AV_PIX_FMT_RGB565LE
    /// packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), big-endian   , X=unused/undefined
    public static let RGB555BE = AV_PIX_FMT_RGB555BE
    /// packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), little-endian, X=unused/undefined
    public static let RGB555LE = AV_PIX_FMT_RGB555LE

    /// packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), big-endian
    public static let BGR565BE = AV_PIX_FMT_BGR565BE
    /// packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), little-endian
    public static let BGR565LE = AV_PIX_FMT_BGR565LE
    /// packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), big-endian   , X=unused/undefined
    public static let BGR555BE = AV_PIX_FMT_BGR555BE
    /// packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), little-endian, X=unused/undefined
    public static let BGR555LE = AV_PIX_FMT_BGR555LE

    public var name: String {
        if let strBytes = av_get_pix_fmt_name(self) {
            return String(cString: strBytes)
        }
        return "unknown"
    }
}

// MARK: - AVSampleFormat

public typealias AVSampleFormat = CFFmpeg.AVSampleFormat

/// Audio sample formats
extension AVSampleFormat {
    /// unsigned 8 bits
    public static let none = AV_SAMPLE_FMT_NONE
    /// unsigned 8 bits
    public static let U8 = AV_SAMPLE_FMT_U8
    /// signed 16 bits
    public static let S16 = AV_SAMPLE_FMT_S16
    /// signed 32 bits
    public static let S32 = AV_SAMPLE_FMT_S32
    /// float
    public static let FLT = AV_SAMPLE_FMT_FLT
    /// double
    public static let DBL = AV_SAMPLE_FMT_DBL
    /// unsigned 8 bits, planar
    public static let U8P = AV_SAMPLE_FMT_U8P
    /// signed 16 bits, planar
    public static let S16P = AV_SAMPLE_FMT_S16P
    /// signed 32 bits, planar
    public static let S32P = AV_SAMPLE_FMT_S32P
    /// float, planar
    public static let FLTP = AV_SAMPLE_FMT_FLTP
    /// double, planar
    public static let DBLP = AV_SAMPLE_FMT_DBLP
    /// signed 64 bits
    public static let S64 = AV_SAMPLE_FMT_S64
    /// signed 64 bits, planar
    public static let S64P = AV_SAMPLE_FMT_S64P
    /// Number of sample formats. DO NOT USE if linking dynamically
    public static let NB = AV_SAMPLE_FMT_NB

    /// The name of sample_fmt, or nil if sample_fmt is not recognized.
    public var name: String {
        if let strBytes = av_get_sample_fmt_name(self) {
            return String(cString: strBytes)
        }
        return "unknown"
    }

    /// Number of bytes per sample or zero if unknown for the given sample format.
    public var bytesPerSample: Int {
        return Int(av_get_bytes_per_sample(self))
    }
}

// MARK: - Audio Channel Laout

// Audio channel layouts
public let AV_CH_LAYOUT_MONO = UInt64(CFFmpeg.AV_CH_LAYOUT_MONO)
public let AV_CH_LAYOUT_STEREO = UInt64(CFFmpeg.AV_CH_LAYOUT_STEREO)
public let AV_CH_LAYOUT_2POINT1 = UInt64(CFFmpeg.AV_CH_LAYOUT_2POINT1)
public let AV_CH_LAYOUT_2_1 = UInt64(CFFmpeg.AV_CH_LAYOUT_2_1)
public let AV_CH_LAYOUT_SURROUND = UInt64(CFFmpeg.AV_CH_LAYOUT_SURROUND)
public let AV_CH_LAYOUT_3POINT1 = UInt64(CFFmpeg.AV_CH_LAYOUT_3POINT1)
public let AV_CH_LAYOUT_4POINT0 = UInt64(CFFmpeg.AV_CH_LAYOUT_4POINT0)
public let AV_CH_LAYOUT_4POINT1 = UInt64(CFFmpeg.AV_CH_LAYOUT_4POINT1)
public let AV_CH_LAYOUT_STEREO_DOWNMIX = UInt64(CFFmpeg.AV_CH_LAYOUT_STEREO_DOWNMIX)

extension UInt64 {

    /// Return the number of channels in the channel layout.
    public var channelCount: Int32 {
        return av_get_channel_layout_nb_channels(self)
    }
}

// MARK: - AVFmtFlag

public enum AVFmtFlag {
    /// Demuxer will use avio_open, no opened file should be provided by the caller.
    public static let noFile = AVFMT_NOFILE
    /// Needs '%d' in filename.
    public static let needNumber = AVFMT_NEEDNUMBER
    /// Show format stream IDs numbers.
    public static let showIDs = AVFMT_SHOW_IDS
    /// Format wants global header.
    public static let globalHeader = AVFMT_GLOBALHEADER
    /// Format does not need / have any timestamps.
    public static let noTimestamps = AVFMT_NOTIMESTAMPS
    /// Use generic index building code.
    public static let genericIndex = AVFMT_GENERIC_INDEX
    /// Format allows timestamp discontinuities. Note, muxers always require valid (monotone) timestamps
    public static let tsDiscont = AVFMT_TS_DISCONT
    /// Format allows variable fps.
    public static let variableFPS = AVFMT_VARIABLE_FPS
    /// Format does not need width/height
    public static let noDimensions = AVFMT_NODIMENSIONS
    /// Format does not require any streams
    public static let noStreams = AVFMT_NOSTREAMS
    /// Format does not allow to fall back on binary search via read_timestamp
    public static let noBinSearch = AVFMT_NOBINSEARCH
    /// Format does not allow to fall back on generic search
    public static let noGenSearch = AVFMT_NOGENSEARCH
    /// Format does not allow seeking by bytes
    public static let noByteSeek = AVFMT_NO_BYTE_SEEK
    /// Format allows flushing. If not set, the muxer will not receive a NULL packet in the write_packet function.
    public static let allowFlush = AVFMT_ALLOW_FLUSH
    /// Format does not require strictly increasing timestamps, but they must still be monotonic
    public static let tsNonstrict = AVFMT_TS_NONSTRICT
    /// Format allows muxing negative timestamps. If not set the timestamp will be shifted in av_write_frame and
    /// av_interleaved_write_frame so they start from 0.
    /// The user or muxer can override this through AVFormatContext.avoid_negative_ts
    public static let tsNegative = AVFMT_TS_NEGATIVE
    /// Seeking is based on PTS
    public static let seekToPTS = AVFMT_SEEK_TO_PTS
}

// MARK: - AVCodecFlag

/// encoding support
///
/// These flags can be passed in AVCodecContext.flags before initialization.
public struct AVCodecFlag {
    /// Place global headers in extradata instead of every keyframe.
    public static let globalHeader = AV_CODEC_FLAG_GLOBAL_HEADER
}

// MARK: - AVIOFlag

/// URL open modes
///
/// The flags argument to avio_open must be one of the following
/// constants, optionally ORed with other flags.
public struct AVIOFlag {
    /// read-only
    public static let read = AVIO_FLAG_READ
    /// write-only
    public static let write = AVIO_FLAG_WRITE
    /// read-write pseudo flag
    public static let readWrite = AVIO_FLAG_READ_WRITE
    /// Use non-blocking mode.
    ///
    /// If this flag is set, operations on the context will return
    /// AVERROR(EAGAIN) if they can not be performed immediately.
    /// If this flag is not set, operations on the context will never return
    /// AVERROR(EAGAIN).
    /// Note that this flag does not affect the opening/connecting of the
    /// context. Connecting a protocol will always block if necessary (e.g. on
    /// network protocols) but never hang (e.g. on busy devices).
    /// Warning: non-blocking protocols is work-in-progress; this flag may be
    /// silently ignored.
    public static let nonBlock = AVIO_FLAG_NONBLOCK
    /// Use direct mode.
    ///
    /// avio_read and avio_write should if possible be satisfied directly
    /// instead of going through a buffer, and avio_seek will always
    /// call the underlying seek function directly.
    public static let direct = AVIO_FLAG_DIRECT
}

// MARK: - AVCodecCap

/// codec capabilities
public struct AVCodecCap {
    /// Audio encoder supports receiving a different number of samples in each call.
    public static let variableFrameSize = AV_CODEC_CAP_VARIABLE_FRAME_SIZE
}

// MARK: - AVRounding

/// Rounding methods.
public typealias AVRounding = CFFmpeg.AVRounding

extension AVRounding {
    /// Round toward zero.
    public static let zero = AV_ROUND_ZERO
    /// Round away from zero.
    public static let inf = AV_ROUND_INF
    /// Round toward -infinity.
    public static let down = AV_ROUND_DOWN
    /// Round toward +infinity.
    public static let up = AV_ROUND_UP
    /// Round to nearest and halfway cases away from zero.
    public static let nearInf = AV_ROUND_NEAR_INF
    ///
    public static let passMinMax = AV_ROUND_PASS_MINMAX
}

/// Rescale a 64-bit integer with rounding to nearest.
///
/// The operation is mathematically equivalent to `a * b / c`, but writing that
/// directly can overflow.
///
/// This function is equivalent to av_rescale_rnd() with #AV_ROUND_NEAR_INF.
public let av_rescale = CFFmpeg.av_rescale

/// Rescale a 64-bit integer with specified rounding.
///
/// The operation is mathematically equivalent to `a * b / c`, but writing that
/// directly can overflow, and does not support different rounding methods.
public let av_rescale_rnd = CFFmpeg.av_rescale_rnd

/// Rescale a 64-bit integer by 2 rational numbers.
///
/// The operation is mathematically equivalent to `a * bq / cq`.
///
/// This function is equivalent to av_rescale_q_rnd() with #AV_ROUND_NEAR_INF.
public let av_rescale_q = CFFmpeg.av_rescale_q

/// Rescale a 64-bit integer by 2 rational numbers with specified rounding.
///
/// The operation is mathematically equivalent to `a * bq / cq`.
public let av_rescale_q_rnd = CFFmpeg.av_rescale_q_rnd

/// Compare two timestamps each in its own time base.
///
/// @return One of the following values:
///         - -1 if `ts_a` is before `ts_b`
///         - 1 if `ts_a` is after `ts_b`
///         - 0 if they represent the same position
///
/// @warning
/// The result of the function is undefined if one of the timestamps is outside
/// the `int64_t` range when represented in the other's timebase.
public let av_compare_ts = CFFmpeg.av_compare_ts

/// Fill the provided buffer with a string containing a timestamp representation.
///
/// - Parameter ts: the timestamp to represent
/// - Returns:
public func av_ts2str(_ ts: Int64) -> String {
    let buf = UnsafeMutablePointer<Int8>.allocate(capacity: AV_TS_MAX_STRING_SIZE)
    buf.initialize(to: 0)
    defer { buf.deallocate() }

    return String(cString: av_ts_make_string(buf, ts))
}

/// Fill the provided buffer with a string containing a timestamp time representation.
///
/// - Parameters:
///   - ts: the timestamp to represent
///   - tb: the timebase of the timestamp
/// - Returns:
public func av_ts2timestr(_ ts: Int64, _ tb: AVRational) -> String {
    let buf = UnsafeMutablePointer<Int8>.allocate(capacity: AV_TS_MAX_STRING_SIZE)
    buf.initialize(to: 0)
    defer { buf.deallocate() }

    var tb = tb
    return String(cString: av_ts_make_time_string(buf, ts, &tb))
}
