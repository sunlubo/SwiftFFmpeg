//
//  AVBitStreamFilter.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/18.
//  Copyright © 2020 sunlubo. All rights reserved.
//

import CFFmpeg

// MARK: - AVBitStreamFilter

typealias CAVBitStreamFilter = CFFmpeg.AVBitStreamFilter

/// A bitstream filter operates on the encoded stream data, and performs bitstream level modifications without performing decoding.
public struct AVBitStreamFilter {
  var native: UnsafePointer<CAVBitStreamFilter>

  init(native: UnsafePointer<CAVBitStreamFilter>) {
    self.native = native
  }

  /// Find a bitstream filter with the specified name.
  ///
  /// - Parameter name: The name of the filter.
  public init?(name: String) {
    guard let ptr = av_bsf_get_by_name(name) else {
      return nil
    }
    self.native = ptr
  }

  /// The name of the filter.
  public var name: String {
    String(cString: native.pointee.name)
  }

  /// The list of codec ids supported by the filter.
  ///
  /// May be empty, in that case the filter works with any codec id.
  public var supportedCodecIds: [AVCodecID] {
    values(native.pointee.codec_ids, until: .none) ?? []
  }

  /// Get all registered bitstream filters.
  public static var supportedFilters: [AVBitStreamFilter] {
    var list = [AVBitStreamFilter]()
    var state: UnsafeMutableRawPointer?
    while let ptr = av_bsf_iterate(&state) {
      list.append(AVBitStreamFilter(native: ptr))
    }
    return list
  }
}

// MARK: - AVBitStreamFilterContext

typealias CAVBSFContext = CFFmpeg.AVBSFContext

/// The bitstream filter state.
public final class AVBitStreamFilterContext {
  var native: UnsafeMutablePointer<CAVBSFContext>!

  /// Creates a null/pass-through context.
  public init() {
    abortIfFail(av_bsf_get_null_filter(&native))
  }

  /// Creates a context for a given bitstream filter.
  ///
  /// - Parameter filter: The filter for which to allocate an instance.
  public init(filter: AVBitStreamFilter) {
    abortIfFail(av_bsf_alloc(filter.native, &native))
  }

  /// Creates a context from the given bitstream filters description string.
  ///
  /// Bitstream filters description syntax:
  ///
  ///     bsf1[=opt1=val1:opt2=val2][,bsf2]
  ///
  /// - Parameter string: The bitstream filters description string.
  public init(description string: String) throws {
    try throwIfFail(av_bsf_list_parse_str(string, &native))
  }

  deinit {
    av_bsf_free(&native)
  }

  /// Parameters of the input stream.
  public var inputParameters: AVCodecParameters {
    AVCodecParameters(native: native.pointee.par_in)
  }

  /// Parameters of the output stream.
  public var outputParameters: AVCodecParameters {
    AVCodecParameters(native: native.pointee.par_out)
  }

  /// The timebase used for the timestamps of the input packets.
  public var inputTimeBase: AVRational {
    get { native.pointee.time_base_in }
    set { native.pointee.time_base_in = newValue }
  }

  /// The timebase used for the timestamps of the output packets.
  public var outputTimeBase: AVRational {
    get { native.pointee.time_base_out }
    set { native.pointee.time_base_out = newValue }
  }

  /// Prepare the filter for use, after all the parameters and options have been set.
  public func initialize() throws {
    try throwIfFail(av_bsf_init(native))
  }

  /// Submit a packet for filtering.
  ///
  /// After sending each packet, the filter must be completely drained by calling
  /// `receivePacket(_:)` repeatedly until it throws `AVError.tryAgain` or `AVError.eof`.
  ///
  /// - Parameter packet: The packet to filter. The bitstream filter will take ownership of
  ///   the packet and reset the contents of pkt. pkt is not touched if an error occurs.
  ///   This parameter may be `nil`, which signals the end of the stream (i.e. no more
  ///   packets will be sent). That will cause the filter to output any packets it
  ///   may have buffered internally.
  /// - Throws: AVError
  public func sendPacket(_ packet: AVPacket?) throws {
    try throwIfFail(av_bsf_send_packet(native, packet?.native))
  }

  /// Retrieve a filtered packet.
  ///
  /// - Note: One input packet may result in several output packets, so after sending
  /// a packet with `sendPacket(_:)`, this function needs to be called
  /// repeatedly until it stops returning 0. It is also possible for a filter to
  /// output fewer packets than were sent to it, so this function may return
  /// `AVError.tryAgain` immediately after a successful `sendPacket(_:)` call.
  ///
  /// - Parameter packet: This struct will be filled with the contents of the filtered packet.
  ///   It is owned by the caller and must be freed using `AVPacket.unref()` when it is no longer needed.
  ///   This parameter should be "clean" (i.e. freshly allocated with `AVPacket.init()` or unreffed with
  ///   `AVPacket.unref()`) when this function is called.
  ///   If this function returns successfully, the contents of pkt will be completely overwritten by the
  ///   returned data. On failure, pkt is not touched.
  /// - Throws:
  ///   - `AVError.tryAgain` if more packets need to be sent to the filter (using `sendPacket(_:)`) to get more output.
  ///   - `AVError.eof` if there will be no further output from the filter.
  ///   - othrer errors.
  public func receivePacket(_ packet: AVPacket) throws {
    try throwIfFail(av_bsf_receive_packet(native, packet.native))
  }

  /// Reset the internal bitstream filter state / flush internal buffers.
  public func flush() {
    av_bsf_flush(native)
  }
}

extension AVBitStreamFilterContext: AVClassSupport, AVOptionSupport {
  public static let `class` = AVClass(native: av_bsf_get_class())

  public func withUnsafeObjectPointer<T>(
    _ body: (UnsafeMutableRawPointer) throws -> T
  ) rethrows -> T {
    try body(native)
  }
}
