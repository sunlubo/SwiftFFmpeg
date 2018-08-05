//
//  CType.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/4.
//

import CFFmpeg

public let AV_INPUT_BUFFER_PADDING_SIZE = Int(CFFmpeg.AV_INPUT_BUFFER_PADDING_SIZE)

public let AV_TS_MAX_STRING_SIZE = Int(CFFmpeg.AV_TS_MAX_STRING_SIZE)

public let AV_ERROR_MAX_STRING_SIZE = Int(CFFmpeg.AV_ERROR_MAX_STRING_SIZE)

extension Int64 {
    /// Undefined timestamp value
    ///
    /// Usually reported by demuxer that work on containers that do not provide
    /// either pts or dts.
    public static let noPTS = swift_AV_NOPTS_VALUE
}

// MARK: - AVRational

/// Rational number (pair of numerator and denominator).
public typealias AVRational = CFFmpeg.AVRational

extension AVRational {
    /// {0,0}
    public static let zero = AVRational(num: 0, den: 0)

    public init(num: Int, den: Int) {
        self.init(num: Int32(num), den: Int32(den))
    }
}

extension AVRational: Equatable {
    public static func == (lhs: AVRational, rhs: AVRational) -> Bool {
        return av_cmp_q(lhs, rhs) == 0
    }
}

// MARK: - AVMediaType

public typealias AVMediaType = CFFmpeg.AVMediaType

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

// MARK: - AVDiscard

public typealias AVDiscard = CFFmpeg.AVDiscard

extension AVDiscard {
    /// discard nothing
    public static let none = AVDISCARD_NONE
    /// discard useless packets like 0 size packets in avi
    public static let `default` = AVDISCARD_DEFAULT
    /// discard all non reference
    public static let nonRef = AVDISCARD_NONREF
    /// discard all bidirectional frames
    public static let bidir = AVDISCARD_BIDIR
    /// discard all non intra frames
    public static let nonIntra = AVDISCARD_NONINTRA
    /// discard all frames except keyframes
    public static let nonKey = AVDISCARD_NONKEY
    /// discard all
    public static let all = AVDISCARD_ALL
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

/// Free a memory block which has been allocated with a function of av_malloc() or av_realloc() family,
/// and set the pointer pointing to it to `NULL`.
public let av_freep = CFFmpeg.av_freep
