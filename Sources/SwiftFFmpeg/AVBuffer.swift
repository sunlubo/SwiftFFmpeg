//
//  AVBuffer.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/24.
//

import CFFmpeg

internal typealias CAVBuffer = CFFmpeg.AVBufferRef

/// A reference to a data buffer.
public final class AVBuffer {
    internal var bufPtr: UnsafeMutablePointer<CAVBuffer>?
    internal var buf: CAVBuffer {
        precondition(bufPtr != nil, "buffer has been freed")
        return bufPtr!.pointee
    }

    internal init(bufPtr: UnsafeMutablePointer<CAVBuffer>) {
        self.bufPtr = bufPtr
    }

    /// Allocate an `AVBuffer` of the given size.
    public init?(size: Int) {
        guard let bufPtr = av_buffer_alloc(Int32(size)) else {
            return nil
        }
        self.bufPtr = bufPtr
    }

    /// The data buffer.
    ///
    /// It is considered writable if and only if this is the only reference to the underlying buffer, in which case
    /// `isWritable` returns true.
    public var data: UnsafeMutablePointer<UInt8> {
        return buf.data
    }

    /// Size of data in bytes.
    public var size: Int {
        return Int(buf.size)
    }

    public var refCount: Int {
        precondition(bufPtr != nil, "buffer has been freed")
        return Int(av_buffer_get_ref_count(bufPtr))
    }

    /// Reallocate a given buffer.
    ///
    /// - Parameter size: required new buffer size.
    /// - Throws: AVError
    ///
    /// - Note: The buffer is actually reallocated with av_realloc() only if it was
    /// initially allocated through av_buffer_realloc(NULL) and there is only one
    /// reference to it (i.e. the one passed to this function). In all other cases
    /// a new buffer is allocated and the data is copied.
    public func realloc(size: Int) throws {
        precondition(bufPtr != nil, "buffer has been freed")
        try throwIfFail(av_buffer_realloc(&bufPtr, Int32(size)))
    }

    /// Check if the buffer is writable.
    ///
    /// - Returns: True if and only if this is the only reference to the underlying buffer.
    public func isWritable() -> Bool {
        precondition(bufPtr != nil, "buffer has been freed")
        return av_buffer_is_writable(bufPtr) > 0
    }

    /// Create a writable reference from a given buffer reference, avoiding data copy if possible.
    ///
    /// Do nothing if the frame is writable, allocate new buffers and copy the data if it is not.
    ///
    /// - Throws: AVError
    public func makeWritable() throws {
        precondition(bufPtr != nil, "buffer has been freed")
        try throwIfFail(av_buffer_make_writable(&bufPtr))
    }

    /// Create a new reference to an `AVBuffer`.
    ///
    /// - Returns: a new `AVBuffer` referring to the same underlying buffer or nil on failure.
    public func ref() -> AVBuffer? {
        precondition(bufPtr != nil, "buffer has been freed")
        return AVBuffer(bufPtr: av_buffer_ref(bufPtr))
    }

    /// Free a given reference and automatically free the buffer if there are no more references to it.
    public func unref() {
        av_buffer_unref(&bufPtr)
    }
}
