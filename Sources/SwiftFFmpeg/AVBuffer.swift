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
    internal let bufPtr: UnsafeMutablePointer<CAVBuffer>
    internal var buf: CAVBuffer { return bufPtr.pointee }

    internal init?(bufPtr: UnsafeMutablePointer<CAVBuffer>?) {
        guard let bufPtr = bufPtr else {
            return nil
        }
        self.bufPtr = bufPtr
    }

    /// The data buffer.
    ///
    /// It is considered writable if and only if this is the only reference to the buffer, in which case
    /// av_buffer_is_writable() returns 1.
    public var data: UnsafeMutablePointer<UInt8> {
        return buf.data
    }

    /// Size of data in bytes.
    public var size: Int {
        return Int(buf.size)
    }

    public var refCount: Int {
        return Int(av_buffer_get_ref_count(bufPtr))
    }

    /// Check if the buffer is writable.
    ///
    /// - Returns: True if the caller may write to the data referred to by buf (which is true if and only if
    ///   buf is the only reference to the underlying AVBuffer). Return false otherwise.
    ///   A positive answer is valid until av_buffer_ref() is called on buf.
    public func isWritable() -> Bool {
        return av_buffer_is_writable(bufPtr) > 0
    }

    /// Create a writable reference from a given buffer reference, avoiding data copy if possible.
    ///
    /// Do nothing if the frame is writable, allocate new buffers and copy the data if it is not.
    ///
    /// - Throws: AVError
    public func makeWritable() throws {
        var ptr: UnsafeMutablePointer<CAVBuffer>? = bufPtr
        try throwIfFail(av_buffer_make_writable(&ptr))
    }
}
