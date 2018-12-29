//
//  AVBuffer.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/24.
//

import CFFmpeg

typealias CAVBuffer = CFFmpeg.AVBufferRef

public final class AVBuffer {
    var cBufferPtr: UnsafeMutablePointer<CAVBuffer>?
    var cBuffer: CAVBuffer {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return cBufferPtr!.pointee
    }

    init(cBufferPtr: UnsafeMutablePointer<CAVBuffer>) {
        self.cBufferPtr = cBufferPtr
    }

    /// Create an AVBuffer from an existing array.
    ///
    /// If this function is successful, data is owned by the AVBuffer. The caller may
    /// only access data through the returned AVBuffer and references derived from it.
    /// If this function fails, data is left untouched.
    ///
    /// - Parameters:
    ///   - data: data array
    ///   - size: size of data in bytes
    ///   - flags: a combination of `AVBuffer.Flag`
    public convenience init?(data: UnsafeMutablePointer<UInt8>, size: Int, flags: AVBuffer.Flag = Flag(rawValue: 0)) {
        let freeFn: @convention(c) (UnsafeMutableRawPointer?, UnsafeMutablePointer<UInt8>?) -> Void = { opaque, data in
            data?.deallocate()
        }
        guard let bufPtr = av_buffer_create(data, Int32(size), freeFn, nil, flags.rawValue) else {
            return nil
        }
        self.init(cBufferPtr: bufPtr)
    }

    /// Create an `AVBuffer` of the given size.
    ///
    /// - Parameter size: size of the buffer
    public convenience init?(size: Int) {
        guard let bufPtr = av_buffer_alloc(Int32(size)) else {
            return nil
        }
        self.init(cBufferPtr: bufPtr)
    }

    /// The data buffer.
    public var data: UnsafeMutablePointer<UInt8> {
        return cBuffer.data
    }

    /// Size of data in bytes.
    public var size: Int {
        return Int(cBuffer.size)
    }

    public var refCount: Int {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return Int(av_buffer_get_ref_count(cBufferPtr))
    }

    /// Reallocate a given buffer.
    ///
    /// - Parameter size: required new buffer size
    /// - Throws: AVError
    public func realloc(size: Int) throws {
        precondition(cBufferPtr != nil, "buffer has been freed")
        try throwIfFail(av_buffer_realloc(&cBufferPtr, Int32(size)))
    }

    /// Check if the buffer is writable.
    ///
    /// - Returns: True if and only if this is the only reference to the underlying buffer.
    public func isWritable() -> Bool {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return av_buffer_is_writable(cBufferPtr) > 0
    }

    /// Create a writable reference from a given buffer reference, avoiding data copy if possible.
    ///
    /// Do nothing if the frame is writable, allocate new buffers and copy the data if it is not.
    ///
    /// - Throws: AVError
    public func makeWritable() throws {
        precondition(cBufferPtr != nil, "buffer has been freed")
        try throwIfFail(av_buffer_make_writable(&cBufferPtr))
    }

    /// Create a new reference to an `AVBuffer`.
    ///
    /// - Returns: a new `AVBuffer` referring to the same underlying buffer or nil on failure.
    public func ref() -> AVBuffer? {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return AVBuffer(cBufferPtr: av_buffer_ref(cBufferPtr))
    }

    /// Free a given reference and automatically free the buffer if there are no more references to it.
    public func unref() {
        av_buffer_unref(&cBufferPtr)
    }

    deinit {
        precondition(cBufferPtr == nil || refCount > 1, "buffer must be freed")
    }
}

extension AVBuffer {

    public struct Flag: OptionSet {
        /// read-only
        public static let read = Flag(rawValue: AV_BUFFER_FLAG_READONLY)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

public final class AVBufferPool {
    var cPoolPtr: OpaquePointer?

    /// Allocate and initialize a buffer pool.
    ///
    /// - Parameter size: size of each buffer in this pool
    public init?(size: Int) {
        guard let poolPtr = av_buffer_pool_init(Int32(size), nil) else {
            return nil
        }
        self.cPoolPtr = poolPtr
    }

    /// Allocate a new AVBuffer, reusing an old buffer from the pool when available.
    /// This function may be called simultaneously from multiple threads.
    ///
    /// - Returns: a reference to the new buffer on success, NULL on error.
    public func getBuffer() -> AVBuffer? {
        guard let bufPtr = av_buffer_pool_get(cPoolPtr) else {
            return nil
        }
        return AVBuffer(cBufferPtr: bufPtr)
    }

    deinit {
        av_buffer_pool_uninit(&cPoolPtr)
    }
}
