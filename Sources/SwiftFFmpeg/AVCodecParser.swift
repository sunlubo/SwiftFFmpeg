//
//  AVCodecParser.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/1.
//

import CFFmpeg

// MARK: - AVCodecParser

typealias CAVCodecParser = CFFmpeg.AVCodecParser

public struct AVCodecParser {
  var native: UnsafeMutablePointer<CAVCodecParser>

  init(native: UnsafeMutablePointer<CAVCodecParser>) {
    self.native = native
  }

  /// several codec IDs are permitted
  public var codecIds: [AVCodecID] {
    let list = [
      native.pointee.codec_ids.0, native.pointee.codec_ids.1, native.pointee.codec_ids.2,
      native.pointee.codec_ids.3,
    ]
    return list.map({ AVCodecID(UInt32($0)) }).filter({ $0 != .none })
  }

  /// Get all registered codec parsers.
  public static var supportedParsers: [AVCodecParser] {
    var list = [AVCodecParser]()
    var state: UnsafeMutableRawPointer?
    while let ptr = av_parser_iterate(&state) {
      list.append(AVCodecParser(native: ptr.mutable))
    }
    return list
  }
}

// MARK: - AVCodecParserContext

public typealias AVCodecParserResult = (
  UnsafeMutablePointer<UInt8>?,  // The parsed buffer or nil if not yet finished.
  Int,  // The number of bytes of the parsed buffer or zero if not yet finished.
  Int  // The number of bytes of the input bitstream used.
)

typealias CAVCodecParserContext = CFFmpeg.AVCodecParserContext

public final class AVCodecParserContext {
  let native: UnsafeMutablePointer<CAVCodecParserContext>
  let codecContext: AVCodecContext

  public init?(codecContext: AVCodecContext) {
    precondition(codecContext.codec != nil, "'AVCodecContext.codec' must not be nil.")

    guard let ptr = av_parser_init(Int32(codecContext.codec!.id.rawValue)) else {
      return nil
    }
    self.native = ptr
    self.codecContext = codecContext
  }

  deinit {
    av_parser_close(native)
  }

  /// Parse a packet.
  ///
  /// - Parameters:
  ///   - data: input buffer.
  ///   - size: buffer size in bytes without the padding.
  ///     I.e. the full buffer size is assumed to be `buf_size + AVConstant.inputBufferPaddingSize`.
  ///     To signal EOF, this should be 0 (so that the last frame can be output).
  ///   - pts: input presentation timestamp.
  ///   - dts: input decoding timestamp.
  ///   - pos: input byte position in stream.
  /// - Returns: The parsed result.
  /// - Throws: AVError
  public func parse(
    data: UnsafePointer<UInt8>,
    size: Int,
    pts: Int64 = AVTimestamp.noPTS,
    dts: Int64 = AVTimestamp.noPTS,
    pos: Int64 = 0
  ) throws -> AVCodecParserResult {
    var buf: UnsafeMutablePointer<UInt8>?
    var bufSize: Int32 = 0
    let ret = av_parser_parse2(
      native,
      codecContext.native,
      &buf,
      &bufSize,
      data,
      Int32(size),
      pts,
      dts,
      pos
    )
    try throwIfFail(ret)

    return (buf, Int(bufSize), Int(ret))
  }
}
