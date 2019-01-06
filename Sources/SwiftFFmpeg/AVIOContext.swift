//
//  AVIOContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/25.
//

import CFFmpeg

// MARK: - AVIODirEntryType

/// Directory entry types.
public typealias AVIODirEntryType = CFFmpeg.AVIODirEntryType

extension AVIODirEntryType {
    public static let unknown = AVIO_ENTRY_UNKNOWN
    public static let blockDevice = AVIO_ENTRY_BLOCK_DEVICE
    public static let characterDevice = AVIO_ENTRY_CHARACTER_DEVICE
    public static let directory = AVIO_ENTRY_DIRECTORY
    public static let namedPipe = AVIO_ENTRY_NAMED_PIPE
    public static let symbolicLink = AVIO_ENTRY_SYMBOLIC_LINK
    public static let socket = AVIO_ENTRY_SOCKET
    public static let file = AVIO_ENTRY_FILE
    public static let server = AVIO_ENTRY_SERVER
    public static let share = AVIO_ENTRY_SHARE
    public static let workgroup = AVIO_ENTRY_WORKGROUP
}

extension AVIODirEntryType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .blockDevice:
            return "block device"
        case .characterDevice:
            return "character device"
        case .directory:
            return "directory"
        case .namedPipe:
            return "pipe"
        case .symbolicLink:
            return "symbolic link"
        case .socket:
            return "socket"
        case .file:
            return "file"
        case .server:
            return "server"
        case .share:
            return "share"
        case .workgroup:
            return "workgroup"
        default:
            return "unknown"
        }
    }
}

// MARK: - AVIODirEntry

typealias CAVIODirEntry = CFFmpeg.AVIODirEntry

/// Describes single entry of the directory.
///
/// Only name and type fields are guaranteed be set.
/// Rest of fields are protocol or/and platform dependent and might be unknown.
public final class AVIODirEntry {
    var cEntryPtr: UnsafeMutablePointer<CAVIODirEntry>!

    /// Filename.
    public let name: String
    /// Type of the entry
    public let type: AVIODirEntryType
    /// File size in bytes, -1 if unknown.
    public let size: Int64
    /// Time of last modification in microseconds since unix epoch, -1 if unknown.
    public let modificationTimestamp: Int64
    /// Time of last access in microseconds since unix epoch, -1 if unknown.
    public let accessTimestamp: Int64
    /// Time of last status change in microseconds since unix epoch, -1 if unknown.
    public let statusChangeTimestamp: Int64
    /// User ID of owner, -1 if unknown.
    public let userId: Int64
    /// Group ID of owner, -1 if unknown.
    public let groupId: Int64
    /// Unix file mode, -1 if unknown.
    public let filemode: Int64

    init(cEntryPtr: UnsafeMutablePointer<CAVIODirEntry>) {
        self.cEntryPtr = cEntryPtr
        self.name = String(cString: cEntryPtr.pointee.name)
        self.type = AVIODirEntryType(rawValue: UInt32(cEntryPtr.pointee.type))
        self.size = cEntryPtr.pointee.size
        self.modificationTimestamp = cEntryPtr.pointee.modification_timestamp
        self.accessTimestamp = cEntryPtr.pointee.access_timestamp
        self.statusChangeTimestamp = cEntryPtr.pointee.status_change_timestamp
        self.userId = cEntryPtr.pointee.user_id
        self.groupId = cEntryPtr.pointee.group_id
        self.filemode = cEntryPtr.pointee.filemode
    }

    deinit {
        avio_free_directory_entry(&cEntryPtr)
    }
}

// MARK: - AVIODirContext

typealias CAVIODirContext = CFFmpeg.AVIODirContext

public final class AVIODirContext {
    let cContextPtr: UnsafeMutablePointer<CAVIODirContext>
    var cContext: CAVIODirContext {
        return cContextPtr.pointee
    }

    private var isOpen: Bool = false

    init(cContextPtr: UnsafeMutablePointer<CAVIODirContext>) {
        self.cContextPtr = cContextPtr
    }

    /// Open directory for reading.
    ///
    /// - Parameters:
    ///   - url: directory to be listed.
    ///   - options: A dictionary filled with protocol-private options.
    /// - Throws: AVError
    public convenience init(url: String, options: [String: String]? = nil) throws {
        var pm: OpaquePointer? = options?.toAVDict()
        defer { av_dict_free(&pm) }

        var pb: UnsafeMutablePointer<CAVIODirContext>!
        try throwIfFail(avio_open_dir(&pb, url, &pm))
        self.init(cContextPtr: pb)
        self.isOpen = true

        dumpUnrecognizedOptions(pm)
    }

    /// Close directory.
    public func close() {
        if isOpen {
            var pb: UnsafeMutablePointer<CAVIODirContext>? = cContextPtr
            avio_close_dir(&pb)
            isOpen = false
        }
    }

    deinit {
        assert(!isOpen, "AVIODirContext must be close")
    }
}

extension AVIODirContext: Sequence {

    public struct Iterator: IteratorProtocol {
        private let dirCtx: AVIODirContext
        private var nextEntry: UnsafeMutablePointer<CAVIODirEntry>?

        init(dirCtx: AVIODirContext) {
            self.dirCtx = dirCtx
        }

        public mutating func next() -> AVIODirEntry? {
            if avio_read_dir(dirCtx.cContextPtr, &nextEntry) >= 0, let entryPtr = nextEntry {
                return AVIODirEntry(cEntryPtr: entryPtr)
            }
            return nil
        }
    }

    public func makeIterator() -> Iterator {
        return Iterator(dirCtx: self)
    }
}

/// Callback for checking whether to abort blocking functions.
/// `AVError.exit` is returned in this case by the interrupted function.
/// During blocking operations, callback is called with opaque as parameter.
/// If the callback returns 1, the blocking operation will be aborted.
public typealias AVIOInterruptCallback = AVIOInterruptCB

// MARK: - AVIOContext

typealias CAVIOContext = CFFmpeg.AVIOContext

/// Bytestream IO Context.
public final class AVIOContext {
    let cContextPtr: UnsafeMutablePointer<CAVIOContext>
    var cContext: CAVIOContext { return cContextPtr.pointee }

    private var isOpen: Bool = false

    init(cContextPtr: UnsafeMutablePointer<CAVIOContext>) {
        self.cContextPtr = cContextPtr
    }

    /// Create and initialize a `AVIOContext` for accessing the resource indicated by url.
    ///
    /// - Note: When the resource indicated by url has been opened in read+write mode, the AVIOContext can be used only for writing.
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
        var pm: OpaquePointer? = options?.toAVDict()
        defer { av_dict_free(&pm) }

        var pb: UnsafeMutablePointer<CAVIOContext>!
        if var cb = interruptCallback {
            try throwIfFail(avio_open2(&pb, url, flags.rawValue, &cb, &pm))
        } else {
            try throwIfFail(avio_open2(&pb, url, flags.rawValue, nil, &pm))
        }
        self.init(cContextPtr: pb)
        self.isOpen = true

        dumpUnrecognizedOptions(pm)
    }

    public func write(_ buf: UnsafePointer<UInt8>, size: Int) {
        avio_write(cContextPtr, buf, Int32(size))
    }

    public func seek(offset: Int64, whence: SeekWhence) throws -> Int {
        let ret = avio_seek(cContextPtr, offset, whence.rawValue)
        try throwIfFail(Int32(ret))
        return Int(ret)
    }

    /// Skip given number of bytes forward.
    public func skip(offset: Int64) throws -> Int {
        let ret = avio_skip(cContextPtr, offset)
        try throwIfFail(Int32(ret))
        return Int(ret)
    }

    /// Returns the file position indicator for the file stream.
    public func tell() throws -> Int {
        let ret = avio_tell(cContextPtr)
        try throwIfFail(Int32(ret))
        return Int(ret)
    }

    /// Get the filesize.
    public func size() throws -> Int64 {
        let ret = avio_size(cContextPtr)
        try throwIfFail(Int32(ret))
        return ret
    }

    /// Checks if the end of the given file stream has been reached.
    public func feof() -> Bool {
        return avio_feof(cContextPtr) != 0
    }

    /// Force flushing of buffered data.
    ///
    /// For write streams, force the buffered data to be immediately written to the output,
    /// without to wait to fill the internal buffer.
    ///
    /// For read streams, discard all currently buffered data, and advance the reported file
    /// position to that of the underlying stream. This does not read new data, and does not
    /// perform any seeks.
    public func flush() {
        avio_flush(cContextPtr)
    }

    /// Read size bytes from `AVIOContext` into buf.
    ///
    /// - Parameters:
    ///   - buf: The buffer into which the data is read.
    ///   - size: The maximum number of bytes read.
    /// - Returns: The total number of bytes read into the buffer.
    /// - Throws: AVError
    public func read(buf: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int {
        let ret = avio_read(cContextPtr, buf, Int32(size))
        try throwIfFail(ret)
        return Int(ret)
    }

    /// Read size bytes from AVIOContext into buf. Unlike `read`, this is allowed to read fewer bytes than requested.
    /// The missing bytes can be read in the next call. This always tries to read at least 1 byte.
    /// Useful to reduce latency in certain cases.
    ///
    /// - Parameters:
    ///   - buf: The buffer into which the data is read.
    ///   - size: The maximum number of bytes read.
    /// - Returns: number of bytes read
    /// - Throws: AVError
    public func partialRead(buf: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int {
        let ret = avio_read_partial(cContextPtr, buf, Int32(size))
        try throwIfFail(ret)
        return Int(ret)
    }

    /// Pause playing
    ///
    /// Only meaningful if using a network streaming protocol (e.g. MMS).
    ///
    /// - Throws: AVError
    public func pause() throws {
        try throwIfFail(avio_pause(cContextPtr, 1))
    }

    /// Resume playing
    ///
    /// Only meaningful if using a network streaming protocol (e.g. MMS).
    ///
    /// - Throws: AVError
    public func resume() throws {
        try throwIfFail(avio_pause(cContextPtr, 0))
    }

    /// Seek to a given timestamp relative to some component stream.
    ///
    /// Only meaningful if using a network streaming protocol (e.g. MMS.).
    ///
    /// - Parameters:
    ///   - streamIndex: The stream index that the timestamp is relative to.
    ///     If stream_index is `-1` the timestamp should be in `avTimeBase`
    ///     units from the beginning of the presentation.
    ///     If a stream_index >= 0 is used and the protocol does not support
    ///     seeking based on component streams, the call will fail.
    ///   - timestamp: timestamp in AVStream.time_base units
    ///     or if there is no stream specified then in `avTimeBase` units.
    ///   - flags: Optional combination of AVSEEK_FLAG_BACKWARD, AVSEEK_FLAG_BYTE
    ///     and AVSEEK_FLAG_ANY. The protocol may silently ignore
    ///     AVSEEK_FLAG_BACKWARD and AVSEEK_FLAG_ANY, but AVSEEK_FLAG_BYTE will
    ///     fail if used and not supported.
    /// - Throws: AVError
    public func seek(streamIndex: Int64, timestamp: Int64, flags: AVFormatContext.SeekFlag) throws -> Int {
        let ret = avio_seek_time(cContextPtr, Int32(streamIndex), timestamp, flags.rawValue)
        try throwIfFail(Int32(ret))
        return Int(ret)
    }

    /// Accept and allocate a client context on a server context.
    public func accept() throws -> AVIOContext {
        var clientCtxPtr: UnsafeMutablePointer<CAVIOContext>!
        try throwIfFail(avio_accept(cContextPtr, &clientCtxPtr))
        return AVIOContext(cContextPtr: clientCtxPtr)
    }

    /// Perform one step of the protocol handshake to accept a new client.
    ///
    /// This function must be called on a client returned by avio_accept() before using it as a read/write context.
    /// It is separate from avio_accept() because it may block.
    /// A step of the handshake is defined by places where the application may decide to change the proceedings.
    /// For example, on a protocol with a request header and a reply header, each one can constitute a step
    /// because the application may use the parameters from the request to change parameters in the reply;
    /// or each individual chunk of the request can constitute a step. If the handshake is already finished,
    /// avio_handshake() does nothing and returns 0 immediately.
    ///
    /// - Returns: `true` on a complete and successful handshake, `false` if the handshake progressed, but is not complete.
    public func handshake() throws -> Bool {
        let ret = avio_handshake(cContextPtr)
        try throwIfFail(ret)
        return ret == 0
    }

    /// Close the resource accessed by the `AVIOContext`.
    ///
    /// The internal buffer is automatically flushed before closing the resource.
    public func close() {
        if isOpen {
            var pb: UnsafeMutablePointer<CAVIOContext>? = cContextPtr
            avio_closep(&pb)
            isOpen = false
        }
    }

    /// Return the name of the protocol that will handle the passed url.
    ///
    /// - Returns: The name of the protocol or nil.
    public static func protocolName(for url: String) -> String? {
        return String(cString: avio_find_protocol_name(url))
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

    deinit {
        assert(!isOpen, "AVIOContext must be close")
    }
}

extension AVIOContext: AVOptionAccessor {

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        return try body(cContextPtr)
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

// MARK: - SeekWhence

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

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
