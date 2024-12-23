//
//  AVIO.swift
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

public typealias AVIOReadHandler = (UnsafeMutableRawPointer?, UnsafeMutablePointer<UInt8>?, Int) ->
  Int
public typealias AVIOWriteHandler = (UnsafeMutableRawPointer?, UnsafePointer<UInt8>?, Int) ->
  Int
public typealias AVIOSeekHandler = (UnsafeMutableRawPointer?, Int64, Int) -> Int64

typealias IOBoxValue = (
  opaque: UnsafeMutableRawPointer,
  read: AVIOReadHandler?,
  write: AVIOWriteHandler?,
  seek: AVIOSeekHandler?
)
typealias IOBox = Box<IOBoxValue>

/// Bytestream IO Context.
public final class AVIOContext {
  var native: UnsafeMutablePointer<CAVIOContext>!
  var opaque: IOBox?
  var owned = false
  var isOpen = false

  init(native: UnsafeMutablePointer<CAVIOContext>) {
    self.native = native
  }

  /// Allocate and initialize an `AVIOContext` for buffered I/O.
  ///
  /// - Parameters:
  ///   - buffer: Memory block for input/output operations via `AVIOContext`.
  ///   - size: The buffer size is very important for performance. For protocols with fixed blocksize
  ///     it should be set to this blocksize. For others a typical size is a cache page, e.g. 4kb.
  ///   - writable: Set to `true` if the buffer should be writable, `false` otherwise.
  ///   - opaque: An opaque pointer to user-specific data.
  ///   - readHandler: A handler for refilling the buffer, may be `nil`.
  ///     For stream protocols, must never return 0 but rather a proper AVERROR code.
  ///   - writeHandler: A handler for writing the buffer contents, may be `nil`.
  ///     The function may not change the input buffers content.
  ///   - seekHandler: A handler for seeking to specified byte position, may be `nil`.
  public init(
    buffer: UnsafeMutablePointer<UInt8>,
    size: Int,
    writable: Bool,
    opaque: UnsafeMutableRawPointer,
    readHandler: AVIOReadHandler?,
    writeHandler: AVIOWriteHandler?,
    seekHandler: AVIOSeekHandler?
  ) {
    // Store everything we want to pass into the c function in a `Box` so we can hand-over the reference.
    let box = IOBox((opaque: opaque, read: readHandler, write: writeHandler, seek: seekHandler))
    var read:
      (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutablePointer<UInt8>?, Int32) -> Int32)?
    if readHandler != nil {
      read = { opaque, buffer, size -> Int32 in
        let value = Unmanaged<IOBox>.fromOpaque(opaque!).takeUnretainedValue().value
        let ret = value.read!(value.opaque, buffer, Int(size))
        return Int32(ret)
      }
    }
    var write:
      (@convention(c) (UnsafeMutableRawPointer?, UnsafePointer<UInt8>?, Int32) -> Int32)?
    if writeHandler != nil {
      write = { opaque, buffer, size -> Int32 in
        let value = Unmanaged<IOBox>.fromOpaque(opaque!).takeUnretainedValue().value
        let ret = value.write!(value.opaque, buffer, Int(size))
        return Int32(ret)
      }
    }
    var seek: (@convention(c) (UnsafeMutableRawPointer?, Int64, Int32) -> Int64)?
    if seekHandler != nil {
      seek = { opaque, offset, size -> Int64 in
        let value = Unmanaged<IOBox>.fromOpaque(opaque!).takeUnretainedValue().value
        return value.seek!(value.opaque, offset, Int(size))
      }
    }
    let ptr = avio_alloc_context(
      buffer,
      Int32(size),
      writable ? 1 : 0,
      Unmanaged.passUnretained(box).toOpaque(),
      read,
      write,
      seek
    )
    guard let ctxPtr = ptr else {
      abort("avio_alloc_context")
    }
    self.native = ctxPtr
    self.opaque = box
    self.owned = true
  }

  /// Create and initialize a `AVIOContext` for accessing the resource indicated by url.
  ///
  /// - Note: When the resource indicated by url has been opened in _read+write_ mode,
  ///   the `AVIOContext` can be used only for writing.
  ///
  /// - Parameters:
  ///   - url: resource to access
  ///   - flags: flags which control how the resource indicated by url is to be opened
  ///   - interruptCallback: an interrupt callback to be used at the protocols level
  ///   - options: A dictionary filled with protocol-private options.
  /// - Throws: AVError
  public convenience init(
    url: String,
    flags: Flag,
    interruptCallback: AVIOInterruptCallback? = nil,
    options: [String: String]? = nil
  ) throws {
    var pm = options?.avDict
    defer { av_dict_free(&pm) }

    var pb: UnsafeMutablePointer<CAVIOContext>!
    if var cb = interruptCallback {
      try throwIfFail(avio_open2(&pb, url, flags.rawValue, &cb, &pm))
    } else {
      try throwIfFail(avio_open2(&pb, url, flags.rawValue, nil, &pm))
    }
    self.init(native: pb)
    self.isOpen = true

    dumpUnrecognizedOptions(pm)
  }

  deinit {
    if owned {
      av_free(native.pointee.buffer)
      avio_context_free(&native)
    }
  }

  /// Writes the contents of a provided data buffer to the receiver.
  public func write(_ buffer: UnsafePointer<UInt8>, size: Int) {
    avio_write(native, buffer, Int32(size))
  }

  /// Sets the file position indicator for the file stream to the value pointed to by offset.
  ///
  /// - Throws: AVError
  public func seek(to offset: Int64, whence: SeekWhence) throws -> Int {
    let ret = avio_seek(native, offset, whence.rawValue)
    try throwIfFail(Int32(ret))
    return Int(ret)
  }

  /// Skip given number of bytes forward.
  ///
  /// - Throws: AVError
  public func skip(to offset: Int64) throws -> Int {
    let ret = avio_skip(native, offset)
    try throwIfFail(Int32(ret))
    return Int(ret)
  }

  /// Returns the file position indicator for the file stream.
  ///
  /// - Throws: AVError
  public func tell() throws -> Int {
    let ret = avio_tell(native)
    try throwIfFail(Int32(ret))
    return Int(ret)
  }

  /// Get the filesize.
  ///
  /// - Throws: AVError
  public func size() throws -> Int64 {
    let ret = avio_size(native)
    try throwIfFail(Int32(ret))
    return ret
  }

  /// Checks if the end of the given file stream has been reached.
  public func feof() -> Bool {
    avio_feof(native) != 0
  }

  /// Force flushing of buffered data.
  ///
  /// For write tracks, force the buffered data to be immediately written to the output,
  /// without to wait to fill the internal buffer.
  ///
  /// For read tracks, discard all currently buffered data, and advance the reported file
  /// position to that of the underlying stream. This does not read new data, and does not
  /// perform any seeks.
  public func flush() {
    avio_flush(native)
  }

  /// Read size bytes from `AVIOContext` into buffer.
  ///
  /// - Parameters:
  ///   - buffer: The buffer into which the data is read.
  ///   - size: The maximum number of bytes read.
  /// - Returns: The total number of bytes read into the buffer.
  /// - Throws: AVError
  public func read(_ buffer: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int {
    let ret = avio_read(native, buffer, Int32(size))
    try throwIfFail(ret)
    return Int(ret)
  }

  /// Read size bytes from `AVIOContext` into buffer. Unlike `read(_:size:)`, this is allowed to
  /// read fewer bytes than requested.
  /// The missing bytes can be read in the next call. This always tries to read at least 1 byte.
  /// Useful to reduce latency in certain cases.
  ///
  /// - Parameters:
  ///   - buffer: The buffer into which the data is read.
  ///   - size: The maximum number of bytes read.
  /// - Returns: number of bytes read
  /// - Throws: AVError
  public func partialRead(_ buffer: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int {
    let ret = avio_read_partial(native, buffer, Int32(size))
    try throwIfFail(ret)
    return Int(ret)
  }

  /// Pause playing.
  ///
  /// - Note: Only meaningful if using a network streaming protocol (e.g. MMS).
  ///
  /// - Throws: AVError
  public func pause() throws {
    try throwIfFail(avio_pause(native, 1))
  }

  /// Resume playing.
  ///
  /// - Note: Only meaningful if using a network streaming protocol (e.g. MMS).
  ///
  /// - Throws: AVError
  public func resume() throws {
    try throwIfFail(avio_pause(native, 0))
  }

  /// Seek to a given timestamp relative to some component stream.
  ///
  /// - Note: Only meaningful if using a network streaming protocol (e.g. MMS.).
  ///
  /// - Parameters:
  ///   - timestamp: timestamp in `AVStream.timebase` units or if there is no stream specified
  ///     then in `AVTimestamp.timebase` units.
  ///   - trackIndex: The stream index that the timestamp is relative to.
  ///     If `trackIndex` is -1 the timestamp should be in `AVTimestamp.timebase` units from
  ///     the beginning of the presentation.
  ///     If a `trackIndex` >= 0 is used and the protocol does not support seeking based on
  ///     component tracks, the call will fail.
  ///   - flags: Optional combination of `SeekFlag.backward`, `SeekFlag.byte` and `SeekFlag.any`.
  ///     The protocol may silently ignore `SeekFlag.backward` and `SeekFlag.any`, but `SeekFlag.byte`
  ///     will fail if used and not supported.
  /// - Throws: AVError
  public func seek(to timestamp: Int64, streamIndex: Int64, flags: AVFormatContext.SeekFlag) throws -> Int {
    let ret = avio_seek_time(native, Int32(streamIndex), timestamp, flags.rawValue)
    try throwIfFail(Int32(ret))
    return Int(ret)
  }

  /// Accept and allocate a client context on a server context.
  ///
  /// - Throws: AVError
  public func accept() throws -> AVIOContext {
    var ptr: UnsafeMutablePointer<CAVIOContext>!
    try throwIfFail(avio_accept(native, &ptr))
    return AVIOContext(native: ptr)
  }

  /// Perform one step of the protocol handshake to accept a new client.
  ///
  /// This function must be called on a client returned by `accept()` before using it as a read/write context.
  /// It is separate from `accept()` because it may block.
  /// A step of the handshake is defined by places where the application may decide to change the proceedings.
  /// For example, on a protocol with a request header and a reply header, each one can constitute a step
  /// because the application may use the parameters from the request to change parameters in the reply;
  /// or each individual chunk of the request can constitute a step. If the handshake is already finished,
  /// `handshake()` does nothing and returns 0 immediately.
  ///
  /// - Returns: `true` on a complete and successful handshake, `false` if the handshake progressed,
  ///   but is not complete.
  /// - Throws: AVError
  public func handshake() throws -> Bool {
    let ret = avio_handshake(native)
    try throwIfFail(ret)
    return ret == 0
  }

  /// Close the resource accessed by the `AVIOContext`.
  ///
  /// The internal buffer is automatically flushed before closing the resource.
  public func close() {
    avio_close(native)
    isOpen = false
  }

  /// Return the name of the protocol that will handle the passed url.
  ///
  /// - Returns: The name of the protocol or nil.
  public static func protocolName(for url: String) -> String? {
    String(cString: avio_find_protocol_name(url))
  }

  /// Returns an array of the input protocols supported by the `AVIOContext`.
  public static var supportedInputProtocols: [String] {
    var protocols = [String]()
    var prev: UnsafeMutableRawPointer?
    while let cString = avio_enum_protocols(&prev, 0) {
      protocols.append(String(cString: cString))
    }
    return protocols
  }

  /// Returns an array of the output protocols supported by the `AVIOContext`.
  public static var supportedOutputProtocols: [String] {
    var protocols = [String]()
    var prev: UnsafeMutableRawPointer?
    while let cString = avio_enum_protocols(&prev, 1) {
      protocols.append(String(cString: cString))
    }
    return protocols
  }
}

extension AVIOContext: AVOptionSupport {

  public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
    try body(native)
  }
}

// MARK: - AVIOContext.Flag

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
    /// If this flag is set, operations on the context will return `AVError.tryAgain` if they can not be
    /// performed immediately.
    /// If this flag is not set, operations on the context will never return `AVError.tryAgain`.
    /// Note that this flag does not affect the opening/connecting of the context. Connecting a protocol
    /// will always block if necessary (e.g. on network protocols) but never hang (e.g. on busy devices).
    ///
    /// - Warning: non-blocking protocols is work-in-progress; this flag may be silently ignored.
    public static let nonBlock = Flag(rawValue: AVIO_FLAG_NONBLOCK)
    /// Use direct mode.
    ///
    /// `read(_:size:)` and `write(_:size:)` should if possible be satisfied directly instead of going through
    /// a buffer, and `seek(to:whence:)` will always call the underlying seek function directly.
    public static let direct = Flag(rawValue: AVIO_FLAG_DIRECT)

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
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

// MARK: - AVIOContext.SeekWhence

extension AVIOContext {
  public struct SeekWhence {
    /// ORing this as the "whence" parameter to a seek function causes it to
    /// return the filesize without seeking anywhere. Supporting this is optional.
    /// If it is not supported then the seek function will return <0.
    public static let size = SeekWhence(rawValue: AVSEEK_SIZE)
    /// Passing this flag as the "whence" parameter to a seek function causes it to
    /// seek by any means (like reopening and linear reading) or other normally unreasonable
    /// means that can be extremely slow.
    /// This may be ignored by the seek code.
    public static let force = SeekWhence(rawValue: AVSEEK_FORCE)

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
  }
}
