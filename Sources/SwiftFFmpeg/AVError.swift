//
//  AVError.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

private let AVERROR = swift_AVERROR
private let AVUNERROR = swift_AVUNERROR

public struct AVError: Error, Equatable, CustomStringConvertible {
    public let code: Int32

    public init(code: Int32) {
        self.code = code
    }

    public var description: String {
        let buf = UnsafeMutablePointer<Int8>.allocate(capacity: AV_ERROR_MAX_STRING_SIZE)
        buf.initialize(to: 0)
        defer { buf.deallocate() }

        return String(cString: av_make_error_string(buf, AV_ERROR_MAX_STRING_SIZE, code))
    }

    /// Resource temporarily unavailable
    public static let EAGAIN = AVError(code: AVERROR(Darwin.EAGAIN))
    /// Invalid argument
    public static let EINVAL = AVError(code: AVERROR(Darwin.EINVAL))
    /// Cannot allocate memory
    public static let ENOMEM = AVError(code: AVERROR(Darwin.ENOMEM))

    /// Bitstream filter not found
    public static let BSF_NOT_FOUND = AVError(code: swift_AVERROR_BSF_NOT_FOUND)
    /// Internal bug, also see AVERROR_BUG2
    public static let BUG = AVError(code: swift_AVERROR_BUG)
    /// Buffer too small
    public static let BUFFER_TOO_SMALL = AVError(code: swift_AVERROR_BUFFER_TOO_SMALL)
    /// Decoder not found
    public static let DECODER_NOT_FOUND = AVError(code: swift_AVERROR_DECODER_NOT_FOUND)
    /// Demuxer not found
    public static let DEMUXER_NOT_FOUND = AVError(code: swift_AVERROR_DEMUXER_NOT_FOUND)
    /// Encoder not found
    public static let ENCODER_NOT_FOUND = AVError(code: swift_AVERROR_ENCODER_NOT_FOUND)
    /// End of file
    public static let EOF = AVError(code: swift_AVERROR_EOF)
    /// Immediate exit was requested; the called function should not be restarted
    public static let EXIT = AVError(code: swift_AVERROR_EXIT)
    /// Generic error in an external library
    public static let EXTERNAL = AVError(code: swift_AVERROR_EXTERNAL)
    /// Filter not found
    public static let FILTER_NOT_FOUND = AVError(code: swift_AVERROR_FILTER_NOT_FOUND)
    /// Invalid data found when processing input
    public static let INVALIDDATA = AVError(code: swift_AVERROR_INVALIDDATA)
    /// Muxer not found
    public static let MUXER_NOT_FOUND = AVError(code: swift_AVERROR_MUXER_NOT_FOUND)
    /// Option not found
    public static let OPTION_NOT_FOUND = AVError(code: swift_AVERROR_OPTION_NOT_FOUND)
    /// Not yet implemented in FFmpeg, patches welcome
    public static let PATCHWELCOME = AVError(code: swift_AVERROR_PATCHWELCOME)
    /// Protocol not found
    public static let PROTOCOL_NOT_FOUND = AVError(code: swift_AVERROR_PROTOCOL_NOT_FOUND)
    /// Stream not found
    public static let STREAM_NOT_FOUND = AVError(code: swift_AVERROR_STREAM_NOT_FOUND)
    /// This is semantically identical to AVERROR_BUG. It has been introduced in Libav after our `AVERROR_BUG` and
    /// with a modified value.
    public static let BUG2 = AVError(code: swift_AVERROR_BUG2)
    /// Unknown error, typically from an external library
    public static let UNKNOWN = AVError(code: swift_AVERROR_UNKNOWN)
    ///  Requested feature is flagged experimental. Set strict_std_compliance if you really want to use it.
    public static let EXPERIMENTAL = AVError(code: swift_AVERROR_EXPERIMENTAL)
    /// Input changed between calls. Reconfiguration is required. (can be OR-ed with AVERROR_OUTPUT_CHANGED)
    public static let INPUT_CHANGED = AVError(code: swift_AVERROR_INPUT_CHANGED)
    /// Output changed between calls. Reconfiguration is required. (can be OR-ed with AVERROR_INPUT_CHANGED)
    public static let OUTPUT_CHANGED = AVError(code: swift_AVERROR_OUTPUT_CHANGED)

    /* HTTP & RTSP errors */
    public static let HTTP_BAD_REQUEST = AVError(code: swift_AVERROR_HTTP_BAD_REQUEST)
    public static let HTTP_UNAUTHORIZED = AVError(code: swift_AVERROR_HTTP_UNAUTHORIZED)
    public static let HTTP_FORBIDDEN = AVError(code: swift_AVERROR_HTTP_FORBIDDEN)
    public static let HTTP_NOT_FOUND = AVError(code: swift_AVERROR_HTTP_NOT_FOUND)
    public static let HTTP_OTHER_4XX = AVError(code: swift_AVERROR_HTTP_OTHER_4XX)
    public static let HTTP_SERVER_ERROR = AVError(code: swift_AVERROR_HTTP_SERVER_ERROR)
}

internal func throwIfFail(_ code: Int32) throws {
    if code < 0 {
        throw AVError(code: code)
    }
}
