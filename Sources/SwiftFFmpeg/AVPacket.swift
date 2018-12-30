//
//  AVPacket.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVPacket

typealias CAVPacket = CFFmpeg.AVPacket

/// This structure stores compressed data. It is typically exported by demuxers
/// and then passed as input to decoders, or received as output from encoders and
/// then passed to muxers.
///
/// For video, it should typically contain one compressed frame. For audio it may
/// contain several compressed frames. Encoders are allowed to output empty packets,
/// with no compressed data, containing only side data (e.g. to update some stream
/// parameters at the end of encoding).
///
/// The semantics of data ownership depends on the `buf` field.
/// If it is set, the packet data is dynamically allocated and is valid indefinitely
/// until a call to `unref` reduces the reference count to 0.
///
/// If the `buf` field is not set `ref` would make a copy instead of increasing the reference count.
///
/// The side data is always allocated with av_malloc(), copied by av_packet_ref() and freed by av_packet_unref().
public final class AVPacket {
    let cPacketPtr: UnsafeMutablePointer<CAVPacket>
    var cPacket: CAVPacket { return cPacketPtr.pointee }

    init(cPacketPtr: UnsafeMutablePointer<CAVPacket>) {
        self.cPacketPtr = cPacketPtr
    }

    /// Allocate an `AVPacket` and set its fields to default values.
    ///
    /// - Note: This only allocates the `AVPacket` itself, not the data buffers.
    ///   Those must be allocated through other means such as av_new_packet.
    public init() {
        guard let packetPtr = av_packet_alloc() else {
            fatalError("av_packet_alloc")
        }
        self.cPacketPtr = packetPtr
    }

    /// A reference to the reference-counted buffer where the packet data is stored.
    /// May be `nil`, then the packet data is not reference-counted.
    public var buffer: AVBuffer? {
        get {
            if let bufPtr = cPacket.buf {
                return AVBuffer(cBufferPtr: bufPtr)
            }
            return nil
        }
        set { cPacketPtr.pointee.buf = newValue?.cBufferPtr }
    }

    /// Presentation timestamp in `AVStream.timebase` units; the time at which the decompressed packet
    /// will be presented to the user.
    ///
    /// Can be `noPTS` if it is not stored in the file.
    public var pts: Int64 {
        get { return cPacket.pts }
        set { cPacketPtr.pointee.pts = newValue }
    }

    /// Decompression timestamp in `AVStream.timebase` units; the time at which the packet is decompressed.
    ///
    /// Can be `noPTS` if it is not stored in the file.
    public var dts: Int64 {
        get { return cPacket.dts }
        set { cPacketPtr.pointee.dts = newValue }
    }

    public var data: UnsafeMutablePointer<UInt8>? {
        get { return cPacket.data }
        set { cPacketPtr.pointee.data = newValue }
    }

    public var size: Int {
        get { return Int(cPacket.size) }
        set { cPacketPtr.pointee.size = Int32(newValue) }
    }

    public var streamIndex: Int {
        get { return Int(cPacket.stream_index) }
        set { cPacketPtr.pointee.stream_index = Int32(newValue) }
    }

    public var flags: Flag {
        get { return Flag(rawValue: cPacket.flags) }
        set { cPacketPtr.pointee.flags = newValue.rawValue }
    }

    /// Duration of this packet in `AVStream.timebase` units, 0 if unknown.
    /// Equals `next_pts - this_pts` in presentation order.
    public var duration: Int64 {
        get { return cPacket.duration }
        set { cPacketPtr.pointee.duration = newValue }
    }

    /// Byte position in stream, -1 if unknown.
    public var position: Int64 {
        get { return cPacket.pos }
        set { cPacketPtr.pointee.pos = newValue }
    }

    /// Convert valid timing fields (timestamps / durations) in a packet from one timebase to another.
    /// Timestamps with unknown values (`noPTS`) will be ignored.
    ///
    /// - Parameters:
    ///   - src: source timebase, in which the timing fields in pkt are expressed.
    ///   - dst: destination timebase, to which the timing fields will be converted.
    public func rescaleTs(from src: AVRational, to dst: AVRational) {
        av_packet_rescale_ts(cPacketPtr, src, dst)
    }

    /// Setup a new reference to the data described by a given packet.
    ///
    /// If src is reference-counted, setup dst as a new reference to the buffer in src.
    /// Otherwise allocate a new buffer in dst and copy the data from src into it.
    ///
    /// All the other fields are copied from src.
    ///
    /// - Throws: AVerror
    public func ref(dst: AVPacket) throws {
        try throwIfFail(av_packet_ref(dst.cPacketPtr, cPacketPtr))
    }

    /// Wipe the packet.
    ///
    /// Unreference the buffer referenced by the packet and reset the remaining packet fields to their default values.
    public func unref() {
        av_packet_unref(cPacketPtr)
    }

    /// Move every field in src to dst and reset src.
    public func moveRef(to dst: AVPacket) {
        av_packet_move_ref(dst.cPacketPtr, cPacketPtr)
    }

    /// Create a new packet that references the same data as src.
    ///
    /// This is a shortcut for `av_packet_alloc() + av_packet_ref()`.
    ///
    /// - Returns: newly created `AVPacket` on success, nil on error.
    public func clone() -> AVPacket? {
        if let ptr = av_packet_clone(cPacketPtr) {
            return AVPacket(cPacketPtr: ptr)
        }
        return nil
    }

    /// Create a writable reference for the data described by a given packet, avoiding data copy if possible.
    ///
    /// - Throws: AVError
    public func makeWritable() throws {
        try throwIfFail(av_packet_make_writable(cPacketPtr))
    }

    deinit {
        var ptr: UnsafeMutablePointer<CAVPacket>? = cPacketPtr
        av_packet_free(&ptr)
    }
}

// MARK: - Flag

extension AVPacket {

    public struct Flag: OptionSet {
        /// The packet contains a keyframe
        public static let key = Flag(rawValue: AV_PKT_FLAG_KEY)
        /// The packet content is corrupted
        public static let corrupt = Flag(rawValue: AV_PKT_FLAG_CORRUPT)
        /// Flag is used to discard packets which are required to maintain valid decoder state
        /// but are not required for output and should be dropped after decoding.
        public static let discard = Flag(rawValue: AV_PKT_FLAG_DISCARD)
        /// The packet comes from a trusted source.
        ///
        /// Otherwise-unsafe constructs such as arbitrary pointers to data outside the packet may be followed.
        public static let trusted = Flag(rawValue: AV_PKT_FLAG_TRUSTED)
        /// Flag is used to indicate packets that contain frames that can be discarded by the decoder.
        /// I.e. Non-reference frames.
        public static let disposable = Flag(rawValue: AV_PKT_FLAG_DISPOSABLE)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension AVPacket.Flag: CustomStringConvertible {

    public var description: String {
        var str = "["
        if contains(.key) { str += "key, " }
        if contains(.corrupt) { str += "corrupt, " }
        if contains(.discard) { str += "discard, " }
        if contains(.trusted) { str += "trusted, " }
        if contains(.disposable) { str += "disposable, " }
        if str.suffix(2) == ", " {
            str.removeLast(2)
        }
        str += "]"
        return str
    }
}
