//
//  AVCodecParser.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/1.
//  Copyright © 2018-2020 sun. All rights reserved.
//

import CFFmpeg

public protocol AVCodecParserDelegate: AnyObject {
  /// Called when a packet parsed.
  func packetParsed(_ packet: AVPacket)
}

public final class AVCodecParser {
  private var native: UnsafeMutablePointer<AVCodecParserContext>
  private var codecContext: AVCodecContext
  private weak var delegate: AVCodecParserDelegate?

  public init(codecContext: AVCodecContext, delegate: AVCodecParserDelegate) throws {
    guard let codecId = codecContext.codec?.id,
      let native = av_parser_init(Int32(codecId.rawValue))
    else {
      throw AVError.decoderNotFound
    }
    self.native = native
    self.codecContext = codecContext
    self.delegate = delegate
  }

  deinit {
    av_parser_close(native)
  }

  /// Parse packets.
  ///
  /// - Parameters:
  ///   - data: The buffer to parse.
  ///   - pts: The presentation timestamp.
  ///   - dts: The decoding timestamp.
  ///   - pos: The byte position in stream.
  public func parse(
    data: UnsafeBufferPointer<UInt8>,
    pts: Int64 = AVTimestamp.noPTS,
    dts: Int64 = AVTimestamp.noPTS,
    pos: Int64 = 0
  ) {
    var data = data
    var outData: UnsafeMutablePointer<UInt8>?
    var outSize: Int32 = 0
    repeat {
      let size = av_parser_parse2(
        native,
        codecContext.cContextPtr,
        &outData, &outSize,
        data.baseAddress, Int32(data.count),
        pts, dts, pos
      )
      data = UnsafeBufferPointer(rebasing: data[Int(size)...])

      guard outSize != 0 else {
        continue
      }

      let packet = AVPacket()
      packet.data = outData
      packet.size = Int(outSize)
      delegate?.packetParsed(packet)
    } while data.count != 0
  }
}

extension AVCodecParser {

  /// Get all registered codec parsers.
  public static var supportedParsers: [AVCodecID] {
    var codecIds: [AVCodecID] = []
    var state: UnsafeMutableRawPointer?
    while let ptr = av_parser_iterate(&state) {
      let list = [
        UInt32(ptr.pointee.codec_ids.0),
        UInt32(ptr.pointee.codec_ids.1),
        UInt32(ptr.pointee.codec_ids.2),
        UInt32(ptr.pointee.codec_ids.3),
      ].map(AVCodecID.init(rawValue:)).filter({ $0 != .none })
      codecIds.append(contentsOf: list)
    }
    return codecIds
  }

  public convenience init(codec: AVCodec, delegate: AVCodecParserDelegate) throws {
    try self.init(codecContext: AVCodecContext(codec: codec), delegate: delegate)
  }
}
