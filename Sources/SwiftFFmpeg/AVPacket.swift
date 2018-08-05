//
//  AVPacket.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVPacketFlag

public struct AVPacketFlag: OptionSet {
    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    /// The packet contains a keyframe
    public static let key = AVPacketFlag(rawValue: AV_PKT_FLAG_KEY)
    /// The packet content is corrupted
    public static let corrupt = AVPacketFlag(rawValue: AV_PKT_FLAG_CORRUPT)
    /// Flag is used to discard packets which are required to maintain valid decoder state
    /// but are not required for output and should be dropped after decoding.
    public static let discard = AVPacketFlag(rawValue: AV_PKT_FLAG_DISCARD)
    /// The packet comes from a trusted source.
    ///
    /// Otherwise-unsafe constructs such as arbitrary pointers to data outside the packet may be followed.
    public static let trusted = AVPacketFlag(rawValue: AV_PKT_FLAG_TRUSTED)
    /// Flag is used to indicate packets that contain frames that can be discarded by the decoder.
    /// I.e. Non-reference frames.
    public static let disposable = AVPacketFlag(rawValue: AV_PKT_FLAG_DISPOSABLE)
}

// MARK: - AVPacket

internal typealias CAVPacket = CFFmpeg.AVPacket

/// This structure stores compressed data.
///
/// It is typically exported by demuxers and then passed as input to decoders,
/// or received as output from encoders and then passed to muxers.
public final class AVPacket {
    internal let packetPtr: UnsafeMutablePointer<CAVPacket>
    internal var packet: CAVPacket { return packetPtr.pointee }

    /// Allocate an `AVPacket` and set its fields to default values.
    public init() {
        guard let packetPtr = av_packet_alloc() else {
            fatalError("av_packet_alloc")
        }
        self.packetPtr = packetPtr
    }

    /// A reference to the reference-counted buffer where the packet data is stored.
    /// May be `nil`, then the packet data is not reference-counted.
    public var buf: AVBuffer? {
        get { return AVBuffer(bufPtr: packet.buf) }
        set { packetPtr.pointee.buf = newValue?.bufPtr }
    }

    /// Presentation timestamp in `AVStream.timebase` units; the time at which
    /// the decompressed packet will be presented to the user.
    ///
    /// Can be `Int64.noPTS` if it is not stored in the file.
    public var pts: Int64 {
        get { return packet.pts }
        set { packetPtr.pointee.pts = newValue }
    }

    /// Decompression timestamp in `AVStream.timebase` units; the time at which
    /// the packet is decompressed.
    ///
    /// Can be `Int64.noPTS` if it is not stored in the file.
    public var dts: Int64 {
        get { return packet.dts }
        set { packetPtr.pointee.dts = newValue }
    }

    public var data: UnsafeMutablePointer<UInt8>? {
        get { return packet.data }
        set { packetPtr.pointee.data = newValue }
    }

    public var size: Int {
        get { return Int(packet.size) }
        set { packetPtr.pointee.size = Int32(newValue) }
    }

    public var streamIndex: Int {
        get { return Int(packet.stream_index) }
        set { packetPtr.pointee.stream_index = Int32(newValue) }
    }

    public var flags: AVPacketFlag {
        get { return AVPacketFlag(rawValue: packet.flags) }
        set { packetPtr.pointee.flags = newValue.rawValue }
    }

    /// Duration of this packet in `AVStream.timebase` units, 0 if unknown.
    /// Equals `next_pts - this_pts` in presentation order.
    public var duration: Int64 {
        get { return packet.duration }
        set { packetPtr.pointee.duration = newValue }
    }

    /// Byte position in stream, -1 if unknown.
    public var pos: Int64 {
        get { return packet.pos }
        set { packetPtr.pointee.pos = newValue }
    }

    /// Wipe the packet.
    ///
    /// Unreference the buffer referenced by the packet and reset the remaining packet fields to their default values.
    public func unref() {
        av_packet_unref(packetPtr)
    }

    /// Convert valid timing fields (timestamps / durations) in a packet from one timebase to another.
    /// Timestamps with unknown values (`Int64.noPTS`) will be ignored.
    ///
    /// - Parameters:
    ///   - src: source timebase, in which the timing fields in pkt are expressed.
    ///   - dst: destination timebase, to which the timing fields will be converted.
    public func rescaleTs(from src: AVRational, to dst: AVRational) {
        av_packet_rescale_ts(packetPtr, src, dst)
    }

    deinit {
        var ptr: UnsafeMutablePointer<CAVPacket>? = packetPtr
        av_packet_free(&ptr)
    }
}
