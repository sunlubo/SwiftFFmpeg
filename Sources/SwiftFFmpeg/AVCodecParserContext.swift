//
//  AVCodecParserContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/1.
//

import CFFmpeg

typealias CAVCodecParserContext = CFFmpeg.AVCodecParserContext

public typealias AVCodecParserResult = (
    Int, // The number of bytes of the input bitstream used.
    Int, // The number of bytes of the parsed buffer or zero if not yet finished.
    UnsafeMutablePointer<UInt8>? // The parsed buffer or nil if not yet finished.
)

public final class AVCodecParserContext {
    private let codecContext: AVCodecContext
    private let cContextPtr: UnsafeMutablePointer<CAVCodecParserContext>
    private var cContext: CAVCodecParserContext { return cContextPtr.pointee }

    public init(codecContext: AVCodecContext) {
        guard let ctxPtr = av_parser_init(Int32(codecContext.codec.id.rawValue)) else {
            fatalError("av_parser_init")
        }
        self.codecContext = codecContext
        self.cContextPtr = ctxPtr
    }

    /// Parse a packet.
    ///
    /// - Parameters:
    ///   - data: input buffer.
    ///   - size: buffer size in bytes without the padding.
    ///     I.e. the full buffer size is assumed to be `buf_size + AV_INPUT_BUFFER_PADDING_SIZE`.
    ///     To signal EOF, this should be 0 (so that the last frame can be output).
    ///   - pts: input presentation timestamp.
    ///   - dts: input decoding timestamp.
    ///   - pos: input byte position in stream.
    /// - Returns: The parsed result.
    /// - Throws: AVError
    public func parse(
        data: UnsafePointer<UInt8>,
        size: Int,
        pts: Int64 = avNoPTS,
        dts: Int64 = avNoPTS,
        pos: Int64 = 0
    ) throws -> AVCodecParserResult {
        var poutbuf: UnsafeMutablePointer<UInt8>?
        var poutbufSize: Int32 = 0
        let ret = av_parser_parse2(
            cContextPtr,
            codecContext.cContextPtr,
            &poutbuf,
            &poutbufSize,
            data,
            Int32(size),
            pts,
            dts,
            pos
        )
        try throwIfFail(ret)

        return (Int(ret), Int(poutbufSize), poutbuf)
    }

    deinit {
        av_parser_close(cContextPtr)
    }
}
