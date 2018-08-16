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

// MARK: - AVIOFlag

/// URL open modes
///
/// The flags argument to avio_open must be one of the following constants, optionally ORed with other flags.
public struct AVIOFlag: OptionSet {
    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    /// read-only
    public static let read = AVIOFlag(rawValue: AVIO_FLAG_READ)
    /// write-only
    public static let write = AVIOFlag(rawValue: AVIO_FLAG_WRITE)
    /// read-write pseudo flag
    public static let readWrite = AVIOFlag(rawValue: AVIO_FLAG_READ_WRITE)
    /// Use non-blocking mode.
    ///
    /// If this flag is set, operations on the context will return `AVError.EAGAIN` if they can not be
    /// performed immediately.
    /// If this flag is not set, operations on the context will never return `AVError.EAGAIN`.
    /// Note that this flag does not affect the opening/connecting of the context. Connecting a protocol
    /// will always block if necessary (e.g. on network protocols) but never hang (e.g. on busy devices).
    ///
    /// - Warning: non-blocking protocols is work-in-progress; this flag may be silently ignored.
    public static let nonBlock = AVIOFlag(rawValue: AVIO_FLAG_NONBLOCK)
    /// Use direct mode.
    ///
    /// avio_read and avio_write should if possible be satisfied directly instead of going through a buffer,
    /// and avio_seek will always call the underlying seek function directly.
    public static let direct = AVIOFlag(rawValue: AVIO_FLAG_DIRECT)
}

// MARK: - AVIOContext

internal typealias CAVIOContext = CFFmpeg.AVIOContext

/// A reference to a data buffer.
public final class AVIOContext {
    internal let ctxPtr: UnsafeMutablePointer<CAVIOContext>
    internal var ctx: CAVIOContext { return ctxPtr.pointee }

    private var needClose = true

    internal init(ctxPtr: UnsafeMutablePointer<CAVIOContext>) {
        self.ctxPtr = ctxPtr
        self.needClose = false
    }

    /// Create and initialize a `AVIOContext` for accessing the resource indicated by url.
    ///
    /// - Parameters:
    ///   - url: resource to access
    ///   - flags: flags which control how the resource indicated by url is to be opened
    /// - Throws: AVError
    public init(url: String, flags: AVIOFlag) throws {
        var pb: UnsafeMutablePointer<CAVIOContext>?
        try throwIfFail(avio_open(&pb, url, flags.rawValue))
        self.ctxPtr = pb!
    }

    deinit {
        if needClose {
            var pb: UnsafeMutablePointer<CAVIOContext>? = ctxPtr
            avio_closep(&pb)
        }
    }
}
