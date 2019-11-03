//
//  AVBitStreamFilter.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/18.
//

import CFFmpeg

// MARK: - AVBitStreamFilter

typealias CAVBitStreamFilter = CFFmpeg.AVBitStreamFilter

public struct AVBitStreamFilter {
    let cFilterPtr: UnsafePointer<CAVBitStreamFilter>
    var cFilter: CAVBitStreamFilter { cFilterPtr.pointee }

    init(cFilterPtr: UnsafePointer<CAVBitStreamFilter>) {
        self.cFilterPtr = cFilterPtr
    }

    /// Find a bitstream filter with the specified name.
    ///
    /// - Parameter name: The name of the bitstream filter.
    public init?(name: String) {
        guard let ptr = av_bsf_get_by_name(name) else {
            return nil
        }
        self.cFilterPtr = ptr
    }

    /// The name of the bitstream filter.
    public var name: String {
        String(cString: cFilter.name)
    }

    /// A list of codec ids supported by the bitstream filter.
    /// May be `nil`, in that case the bitstream filter works with any codec id.
    public var codecIds: [AVCodecID]? {
        values(cFilter.codec_ids, until: .none)
    }

    /// Get all registered bitstream filters.
    public static var supportedFilters: [AVBitStreamFilter] {
        var list = [AVBitStreamFilter]()
        var state: UnsafeMutableRawPointer?
        while let ptr = av_bsf_iterate(&state) {
            list.append(AVBitStreamFilter(cFilterPtr: ptr))
        }
        return list
    }
}

extension AVBitStreamFilter: CustomStringConvertible {

    public var description: String {
        name
    }
}

// MARK: - AVBSFContext

typealias CAVBSFContext = CFFmpeg.AVBSFContext

/// The bitstream filter state.
public final class AVBitStreamFilterContext {
    let cContextPtr: UnsafeMutablePointer<CAVBSFContext>
    var cContext: CAVBSFContext { cContextPtr.pointee }

    init(cContextPtr: UnsafeMutablePointer<CAVBSFContext>) {
        self.cContextPtr = cContextPtr
    }

    /// Get null/pass-through bitstream filter.
    public init() {
        var ptr: UnsafeMutablePointer<CAVBSFContext>!
        abortIfFail(av_bsf_get_null_filter(&ptr))
        self.cContextPtr = ptr
    }

    /// Allocate a context for a given bitstream filter.
    /// The caller must fill in the context parameters as described in the documentation
    /// and then call `initialize()` before sending any data to the filter.
    ///
    /// - Parameter filter: the filter for which to allocate an instance.
    public init(filter: AVBitStreamFilter) {
        var ptr: UnsafeMutablePointer<CAVBSFContext>!
        abortIfFail(av_bsf_alloc(filter.cFilterPtr, &ptr))
        self.cContextPtr = ptr
    }

    /// Parse string describing list of bitstream filters and create single
    /// `AVBSFContext` describing the whole chain of bitstream filters.
    ///
    /// - Parameter str: String describing chain of bitstream filters in format
    ///   `bsf1[=opt1=val1:opt2=val2][,bsf2]`.
    public init(str: String) {
        var ptr: UnsafeMutablePointer<CAVBSFContext>!
        abortIfFail(av_bsf_list_parse_str(str, &ptr))
        self.cContextPtr = ptr
    }

    /// Prepare the filter for use, after all the parameters and options have been set.
    public func initialize() throws {
        try throwIfFail(av_bsf_init(cContextPtr))
    }

    /// Submit a packet for filtering.
    ///
    /// After sending each packet, the filter must be completely drained by calling
    /// `receivePacket(_:)` repeatedly until it returns `AVError.tryAgain` or `AVError.eof`.
    ///
    /// - Parameter packet: the packet to filter. The bitstream filter will take ownership of
    ///   the packet and reset the contents of pkt. pkt is not touched if an error occurs.
    ///   This parameter may be `nil`, which signals the end of the stream (i.e. no more
    ///   packets will be sent). That will cause the filter to output any packets it
    ///   may have buffered internally.
    /// - Throws: AVError
    public func sendPacket(_ packet: AVPacket?) throws {
        try throwIfFail(av_bsf_send_packet(cContextPtr, packet?.cPacketPtr))
    }

    /// Retrieve a filtered packet.
    ///
    /// - Note: one input packet may result in several output packets, so after sending
    /// a packet with `sendPacket(_:)`, this function needs to be called
    /// repeatedly until it stops returning 0. It is also possible for a filter to
    /// output fewer packets than were sent to it, so this function may return
    /// `AVError.tryAgain` immediately after a successful `sendPacket(_:)` call.
    ///
    /// - Parameter packet: this struct will be filled with the contents of the filtered packet.
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
        try throwIfFail(av_bsf_receive_packet(cContextPtr, packet.cPacketPtr))
    }

    /// Reset the internal bitstream filter state / flush internal buffers.
    public func flush() {
        av_bsf_flush(cContextPtr)
    }

    deinit {
        var pb: UnsafeMutablePointer<CAVBSFContext>? = cContextPtr
        av_bsf_free(&pb)
    }
}

extension AVBitStreamFilterContext: AVClassSupport, AVOptionSupport {
    public static let `class` = AVClass(cClassPtr: av_bsf_get_class())

    public func withUnsafeObjectPointer<T>(
        _ body: (UnsafeMutableRawPointer) throws -> T
    ) rethrows -> T {
        try body(cContextPtr)
    }
}
