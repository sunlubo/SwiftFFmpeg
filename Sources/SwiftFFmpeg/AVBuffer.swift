//
//  AVBuffer.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/24.
//

import CFFmpeg

typealias CAVBuffer = CFFmpeg.AVBufferRef

public final class AVBuffer {
  var native: UnsafeMutablePointer<CAVBuffer>?

  init(native: UnsafeMutablePointer<CAVBuffer>) {
    self.native = native
  }

  /// Create an `AVBuffer` of the given size.
  ///
  /// - Parameter size: size of the buffer
  init(size: Int) {
    self.native = av_buffer_alloc(size)
  }

  /// The data buffer.
  public var data: UnsafeMutablePointer<UInt8> {
    precondition(native != nil, "Buffer has been freed.")
    return native!.pointee.data
  }

  /// The size of data in bytes.
  public var size: Int {
    precondition(native != nil, "Buffer has been freed.")
    return Int(native!.pointee.size)
  }

  /// The reference count held by the buffer.
  public var refCount: Int {
    precondition(native != nil, "buffer has been freed")
    return Int(av_buffer_get_ref_count(native))
  }

  /// A Boolean value indicating whether this buffer is writable.
  /// `true` if and only if this is the only reference to the underlying buffer.
  public var isWritable: Bool {
    precondition(native != nil, "Buffer has been freed.")
    return av_buffer_is_writable(native) > 0
  }

  /// Reallocate a given buffer.
  ///
  /// - Parameter size: required new buffer size
  public func realloc(size: Int) {
    precondition(native != nil, "Buffer has been freed.")
    abortIfFail(av_buffer_realloc(&native, size))
  }

  /// Create a writable reference from a given buffer reference, avoiding data copy if possible.
  ///
  /// Do nothing if the frame is writable, allocate new buffers and copy the data if it is not.
  public func makeWritable() {
    precondition(native != nil, "Buffer has been freed.")
    abortIfFail(av_buffer_make_writable(&native))
  }

  /// Create a new reference to an `AVBuffer`.
  ///
  /// - Returns: a new `AVBuffer` referring to the same underlying buffer or `nil` on failure.
  public func ref() -> AVBuffer? {
    precondition(native != nil, "Buffer has been freed.")
    return AVBuffer(native: av_buffer_ref(native))
  }

  /// Free a given reference and automatically free the buffer if there are no more references to it.
  public func unref() {
    av_buffer_unref(&native)
  }
}
