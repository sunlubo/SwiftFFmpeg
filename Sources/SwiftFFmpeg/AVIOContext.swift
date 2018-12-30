//
//  AVIOContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/25.
//

import CFFmpeg

/// Callback for checking whether to abort blocking functions.
/// `AVError.exit` is returned in this case by the interrupted function.
/// During blocking operations, callback is called with opaque as parameter.
/// If the callback returns 1, the blocking operation will be aborted.
public typealias AVIOInterruptCallback = AVIOInterruptCB

// MARK: - AVIOContext

typealias CAVIOContext = CFFmpeg.AVIOContext

/// A reference to a data buffer.
public final class AVIOContext {
    let cContextPtr: UnsafeMutablePointer<CAVIOContext>
    var cContext: CAVIOContext { return cContextPtr.pointee }

    private var needClose = true

    init(cContextPtr: UnsafeMutablePointer<CAVIOContext>) {
        self.cContextPtr = cContextPtr
        self.needClose = false
    }

    /// Create and initialize a `AVIOContext` for accessing the resource indicated by url.
    ///
    /// - Parameters:
    ///   - url: resource to access
    ///   - flags: flags which control how the resource indicated by url is to be opened
    /// - Throws: AVError
    public init(url: String, flags: AVIOContext.Flag) throws {
        var pb: UnsafeMutablePointer<CAVIOContext>?
        try throwIfFail(avio_open(&pb, url, flags.rawValue))
        self.cContextPtr = pb!
    }

    deinit {
        if needClose {
            var pb: UnsafeMutablePointer<CAVIOContext>? = cContextPtr
            avio_closep(&pb)
        }
    }
}

// MARK: - Flag

extension AVIOContext {

    /// URL open modes
    ///
    /// The flags argument to avio_open must be one of the following constants, optionally ORed with other flags.
    public struct Flag: OptionSet {
        /// read-only
        public static let read = Flag(rawValue: AVIO_FLAG_READ)
        /// write-only
        public static let write = Flag(rawValue: AVIO_FLAG_WRITE)
        /// read-write pseudo flag
        public static let readWrite = Flag(rawValue: AVIO_FLAG_READ_WRITE)
        /// Use non-blocking mode.
        ///
        /// If this flag is set, operations on the context will return `AVError.EAGAIN` if they can not be
        /// performed immediately.
        /// If this flag is not set, operations on the context will never return `AVError.EAGAIN`.
        /// Note that this flag does not affect the opening/connecting of the context. Connecting a protocol
        /// will always block if necessary (e.g. on network protocols) but never hang (e.g. on busy devices).
        ///
        /// - Warning: non-blocking protocols is work-in-progress; this flag may be silently ignored.
        public static let nonBlock = Flag(rawValue: AVIO_FLAG_NONBLOCK)
        /// Use direct mode.
        ///
        /// avio_read and avio_write should if possible be satisfied directly instead of going through a buffer,
        /// and avio_seek will always call the underlying seek function directly.
        public static let direct = Flag(rawValue: AVIO_FLAG_DIRECT)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension AVIOContext.Flag: CustomStringConvertible {

    public var description: String {
        var str = "["
        if contains(.read) { str += "read, " }
        if contains(.write) { str += "write, " }
        if contains(.readWrite) { str += "readWrite, " }
        if contains(.nonBlock) { str += "nonBlock, " }
        if contains(.direct) { str += "direct, " }
        if str.suffix(2) == ", " {
            str.removeLast(2)
        }
        str += "]"
        return str
    }
}
