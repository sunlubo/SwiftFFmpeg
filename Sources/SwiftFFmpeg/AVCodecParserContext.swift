//
//  AVCodecParserContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/1.
//

import CFFmpeg

internal typealias CAVCodecParserContext = CFFmpeg.AVCodecParserContext

public final class AVCodecParserContext {
    private let codecCtx: AVCodecContext

    internal let ctxPtr: UnsafeMutablePointer<CAVCodecParserContext>
    internal var ctx: CAVCodecParserContext { return ctxPtr.pointee }

    public init(codecCtx: AVCodecContext) {
        self.codecCtx = codecCtx
        self.ctxPtr = av_parser_init(Int32(codecCtx.codec.id.rawValue))
    }

    /// Parse a packet.
    ///
    /// - Parameters:
    ///   - data: input buffer.
    ///   - dataSize: buffer size in bytes without the padding.
    ///     I.e. the full buffer size is assumed to be buf_size + AV_INPUT_BUFFER_PADDING_SIZE.
    ///     To signal EOF, this should be 0 (so that the last frame can be output).
    ///   - packet: packet
    /// - Returns: the number of bytes of the input bitstream used.
    public func parse(data: UnsafePointer<UInt8>, dataSize: Int, packet: AVPacket) -> Int {
        var dataPtr: UnsafeMutablePointer<UInt8>?
        let ret = av_parser_parse2(ctxPtr, codecCtx.ctxPtr, &dataPtr, &packet.packetPtr.pointee.size, data, Int32(dataSize), AV_NOPTS_VALUE, AV_NOPTS_VALUE, 0)
        packet.packetPtr.pointee.data = dataPtr
        return Int(ret)
    }

    deinit {
        av_parser_close(ctxPtr)
    }
}
