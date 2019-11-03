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

    /// Create an `AVBuffer` of the given size. (only for test)
    ///
    /// - Parameter size: size of the buffer
    init(size: Int) {
        guard let bufPtr = av_buffer_alloc(Int32(size)) else {
            abort("av_buffer_alloc")
        }
        self.cBufferPtr = bufPtr
    }

    /// The data buffer.
    public var data: UnsafeMutablePointer<UInt8> {
        cBuffer.data
    }

    /// The size of data in bytes.
    public var size: Int {
        Int(cBuffer.size)
    }

    /// The reference count held by the buffer.
    public var refCount: Int {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return Int(av_buffer_get_ref_count(cBufferPtr))
    }

    /// A Boolean value indicating whether this buffer is writable.
    /// `true` if and only if this is the only reference to the underlying buffer.
    public var isWritable: Bool {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return av_buffer_is_writable(cBufferPtr) > 0
    }

    /// Reallocate a given buffer.
    ///
    /// - Parameter size: required new buffer size
    public func realloc(size: Int) {
        precondition(cBufferPtr != nil, "buffer has been freed")
        abortIfFail(av_buffer_realloc(&cBufferPtr, Int32(size)))
    }

    /// Create a writable reference from a given buffer reference, avoiding data copy if possible.
    ///
    /// Do nothing if the frame is writable, allocate new buffers and copy the data if it is not.
    public func makeWritable() {
        precondition(cBufferPtr != nil, "buffer has been freed")
        abortIfFail(av_buffer_make_writable(&cBufferPtr))
    }

    /// Create a new reference to an `AVBuffer`.
    ///
    /// - Returns: a new `AVBuffer` referring to the same underlying buffer or `nil` on failure.
    public func ref() -> AVBuffer? {
        precondition(cBufferPtr != nil, "buffer has been freed")
        return AVBuffer(cBufferPtr: av_buffer_ref(cBufferPtr))
    }

    /// Free a given reference and automatically free the buffer if there are no more references to it.
    public func unref() {
        av_buffer_unref(&cBufferPtr)
    }
}
