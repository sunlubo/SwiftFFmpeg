//
//  AVFormatContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVInputFormat

typealias CAVInputFormat = CFFmpeg.AVInputFormat

public struct AVInputFormat {
    let cFormatPtr: UnsafeMutablePointer<CAVInputFormat>
    var cFormat: CAVInputFormat { return cFormatPtr.pointee }

    init(cFormatPtr: UnsafeMutablePointer<CAVInputFormat>) {
        self.cFormatPtr = cFormatPtr
    }

    /// Find `AVInputFormat` based on the short name of the input format.
    ///
    /// - Parameter name: name of the input format
    public init?(name: String) {
        guard let fmtPtr = av_find_input_format(name) else {
            return nil
        }
        self.init(cFormatPtr: fmtPtr)
    }

    /// A comma separated list of short names for the format.
    public var name: String {
        return String(cString: cFormat.name)
    }

    /// Descriptive name for the format, meant to be more human-readable than name.
    public var longName: String {
        return String(cString: cFormat.long_name)
    }

    public var flags: Flag {
        get { return Flag(rawValue: cFormat.flags) }
        set { cFormatPtr.pointee.flags = newValue.rawValue }
    }

    /// If extensions are defined, then no probe is done. You should usually not use extension format guessing
    /// because it is not reliable enough.
    public var extensions: String? {
        return String(cString: cFormat.extensions)
    }

    /// Comma-separated list of mime types.
    public var mimeType: String? {
        return String(cString: cFormat.mime_type)
    }

    /// Get all registered demuxers.
    public static var supportedFormats: [AVInputFormat] {
        var list = [AVInputFormat]()
        var state: UnsafeMutableRawPointer?
        while let fmtPtr = av_demuxer_iterate(&state) {
            list.append(AVInputFormat(cFormatPtr: fmtPtr.mutable))
        }
        return list
    }
}

extension AVInputFormat {

    /// Flags used by `AVInputFormat.flags`.
    public struct Flag: OptionSet {
        /// Demuxer will use avio_open, no opened file should be provided by the caller.
        public static let noFile = Flag(rawValue: AVFMT_NOFILE)
        /// Needs '%d' in filename.
        public static let needNumber = Flag(rawValue: AVFMT_NEEDNUMBER)
        /// Show format stream IDs numbers.
        public static let showIDs = Flag(rawValue: AVFMT_SHOW_IDS)
        /// Use generic index building code.
        public static let genericIndex = Flag(rawValue: AVFMT_GENERIC_INDEX)
        /// Format allows timestamp discontinuities. Note, muxers always require valid (monotone) timestamps.
        public static let tsDiscont = Flag(rawValue: AVFMT_TS_DISCONT)
        /// Format does not allow to fall back on binary search via read_timestamp.
        public static let noBinSearch = Flag(rawValue: AVFMT_NOBINSEARCH)
        /// Format does not allow to fall back on generic search.
        public static let noGenSearch = Flag(rawValue: AVFMT_NOGENSEARCH)
        /// Format does not allow seeking by bytes.
        public static let noByteSeek = Flag(rawValue: AVFMT_NO_BYTE_SEEK)
        /// Seeking is based on PTS.
        public static let seekToPTS = Flag(rawValue: AVFMT_SEEK_TO_PTS)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension AVInputFormat.Flag: CustomStringConvertible {

    public var description: String {
        var str = "["
        if contains(.noFile) { str += "noFile, " }
        if contains(.needNumber) { str += "needNumber, " }
        if contains(.showIDs) { str += "showIDs, " }
        if contains(.genericIndex) { str += "genericIndex, " }
        if contains(.tsDiscont) { str += "tsDiscont, " }
        if contains(.noBinSearch) { str += "noBinSearch, " }
        if contains(.noGenSearch) { str += "noGenSearch, " }
        if contains(.noByteSeek) { str += "noByteSeek, " }
        if contains(.seekToPTS) { str += "seekToPTS, " }
        if str.suffix(2) == ", " {
            str.removeLast(2)
        }
        str += "]"
        return str
    }
}

extension AVInputFormat: AVOptionAccessor {

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        var tmp = cFormat.priv_class
        return try withUnsafeMutablePointer(to: &tmp) { ptr in
            try body(ptr)
        }
    }
}

// MARK: - AVOutputFormat

typealias CAVOutputFormat = CFFmpeg.AVOutputFormat

public struct AVOutputFormat {
    let cFormatPtr: UnsafeMutablePointer<CAVOutputFormat>
    var cFormat: CAVOutputFormat { return cFormatPtr.pointee }

    init(cFormatPtr: UnsafeMutablePointer<CAVOutputFormat>) {
        self.cFormatPtr = cFormatPtr
    }

    /// Find `AVOutputFormat` based on the short name of the output format.
    ///
    /// - Parameter name: name of the input format
    public init?(name: String) {
        guard let fmtPtr = av_guess_format(name, nil, nil) else {
            return nil
        }
        self.init(cFormatPtr: fmtPtr)
    }

    /// A comma separated list of short names for the format.
    public var name: String {
        return String(cString: cFormat.name)
    }

    /// Descriptive name for the format, meant to be more human-readable than name.
    public var longName: String {
        return String(cString: cFormat.long_name)
    }

    /// If extensions are defined, then no probe is done. You should usually not use extension format guessing
    /// because it is not reliable enough.
    public var extensions: String? {
        return String(cString: cFormat.extensions)
    }

    /// Comma-separated list of mime types.
    public var mimeType: String? {
        return String(cString: cFormat.mime_type)
    }

    /// default audio codec
    public var audioCodec: AVCodecID {
        return cFormat.audio_codec
    }

    /// default video codec
    public var videoCodec: AVCodecID {
        return cFormat.video_codec
    }

    /// default subtitle codec
    public var subtitleCodec: AVCodecID {
        return cFormat.subtitle_codec
    }

    public var flags: AVOutputFormat.Flag {
        get { return Flag(rawValue: cFormat.flags) }
        set { cFormatPtr.pointee.flags = newValue.rawValue }
    }

    /// Get all registered muxers.
    public static var supportedFormats: [AVOutputFormat] {
        var list = [AVOutputFormat]()
        var state: UnsafeMutableRawPointer?
        while let fmtPtr = av_muxer_iterate(&state) {
            list.append(AVOutputFormat(cFormatPtr: fmtPtr.mutable))
        }
        return list
    }
}

extension AVOutputFormat {

    /// Flags used by `AVOutputFormat.flags`.
    public struct Flag: OptionSet {
        /// Demuxer will use avio_open, no opened file should be provided by the caller.
        public static let noFile = Flag(rawValue: AVFMT_NOFILE)
        /// Needs '%d' in filename.
        public static let needNumber = Flag(rawValue: AVFMT_NEEDNUMBER)
        /// Format wants global header.
        public static let globalHeader = Flag(rawValue: AVFMT_GLOBALHEADER)
        /// Format does not need / have any timestamps.
        public static let noTimestamps = Flag(rawValue: AVFMT_NOTIMESTAMPS)
        /// Format allows variable fps.
        public static let variableFPS = Flag(rawValue: AVFMT_VARIABLE_FPS)
        /// Format does not need width/height.
        public static let noDimensions = Flag(rawValue: AVFMT_NODIMENSIONS)
        /// Format does not require any streams.
        public static let noStreams = Flag(rawValue: AVFMT_NOSTREAMS)
        /// Format allows flushing. If not set, the muxer will not receive a nil packet in the write_packet function.
        public static let allowFlush = Flag(rawValue: AVFMT_ALLOW_FLUSH)
        /// Format does not require strictly increasing timestamps, but they must still be monotonic.
        public static let tsNonstrict = Flag(rawValue: AVFMT_TS_NONSTRICT)
        /// Format allows muxing negative timestamps. If not set the timestamp will be shifted in `writeFrame` and
        /// `interleavedWriteFrame` so they start from 0.
        /// The user or muxer can override this through AVFormatContext.avoid_negative_ts.
        public static let tsNegative = Flag(rawValue: AVFMT_TS_NEGATIVE)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension AVOutputFormat.Flag: CustomStringConvertible {

    public var description: String {
        var str = "["
        if contains(.noFile) { str += "noFile, " }
        if contains(.needNumber) { str += "needNumber, " }
        if contains(.globalHeader) { str += "globalHeader, " }
        if contains(.noTimestamps) { str += "noTimestamps, " }
        if contains(.variableFPS) { str += "variableFPS, " }
        if contains(.noDimensions) { str += "noDimensions, " }
        if contains(.noStreams) { str += "noStreams, " }
        if contains(.allowFlush) { str += "allowFlush, " }
        if contains(.tsNonstrict) { str += "tsNonstrict, " }
        if contains(.tsNegative) { str += "tsNegative, " }
        if str.suffix(2) == ", " {
            str.removeLast(2)
        }
        str += "]"
        return str
    }
}

extension AVOutputFormat: AVOptionAccessor {

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        var tmp = cFormat.priv_class
        return try withUnsafeMutablePointer(to: &tmp) { ptr in
            try body(ptr)
        }
    }
}

// MARK: - AVFormatContext

typealias CAVFormatContext = CFFmpeg.AVFormatContext

/// Format I/O context.
public final class AVFormatContext {
    public static let `class` = AVClass(cClassPtr: avformat_get_class())

    var cContextPtr: UnsafeMutablePointer<CAVFormatContext>!
    var cContext: CAVFormatContext { return cContextPtr.pointee }

    private var ioContext: AVIOContext?

    init(cContextPtr: UnsafeMutablePointer<CAVFormatContext>) {
        self.cContextPtr = cContextPtr
    }

    /// Allocate an `AVFormatContext`.
    public init() {
        guard let ctxPtr = avformat_alloc_context() else {
            fatalError("avformat_alloc_context")
        }
        self.cContextPtr = ctxPtr
    }

    /// Input or output URL.
    ///
    /// - demuxing: set by `openInput`, initialized to an empty string if url parameter was nil in `openInput`.
    /// - muxing: may be set by the caller before calling `writeHeader` (or avformat_init_output() if that is
    ///   called first) to a string which is freeable by av_free(). Set to an empty string if it was nil in
    ///   avformat_init_output().
    public var url: String? {
        return String(cString: cContext.url)
    }

    /// I/O context.
    ///
    /// - demuxing: Either set by the user before `openInput` (then the user must close it manually)
    ///   or set by `openInput`.
    /// - muxing: Set by the user before `writeHeader`. The caller must take care of closing / freeing
    ///   the IO context.
    internal var pb: AVIOContext? {
        get {
            if let ctxPtr = cContext.pb {
                return AVIOContext(cContextPtr: ctxPtr)
            }
            return nil
        }
        set {
            ioContext = newValue
            return cContextPtr.pointee.pb = newValue?.cContextPtr
        }
    }

    /// Number of streams.
    public var streamCount: Int {
        return Int(cContext.nb_streams)
    }

    /// A list of all streams in the file. New streams are created with `addStream`.
    ///
    /// - demuxing: Streams are created by libavformat in `openInput`. If `noHeader` is set in `flags`,
    ///   then new streams may also appear in `readFrame`.
    /// - muxing: Streams are created by the user before `writeHeader`.
    public var streams: [AVStream] {
        var list = [AVStream]()
        for i in 0..<streamCount {
            let stream = cContext.streams.advanced(by: i).pointee!
            list.append(AVStream(cStreamPtr: stream))
        }
        return list
    }

    public var videoStream: AVStream? {
        return streams.first { $0.mediaType == .video }
    }

    public var audioStream: AVStream? {
        return streams.first { $0.mediaType == .audio }
    }

    public var subtitleStream: AVStream? {
        return streams.first { $0.mediaType == .subtitle }
    }

    /// Flags modifying the (de)muxer behaviour.
    ///
    /// Set by the user before `openInput` / `writeHeader`.
    public var flags: Flag {
        get { return Flag(rawValue: cContext.flags) }
        set { cContextPtr.pointee.flags = newValue.rawValue }
    }

    /// Metadata that applies to the whole file.
    ///
    /// - demuxing: Set by libavformat in `openInput`.
    /// - muxing: May be set by the caller before `writeHeader`.
    public var metadata: [String: String] {
        var dict = [String: String]()
        var tag: UnsafeMutablePointer<AVDictionaryEntry>?
        while let next = av_dict_get(cContext.metadata, "", tag, AV_DICT_IGNORE_SUFFIX) {
            dict[String(cString: next.pointee.key)] = String(cString: next.pointee.value)
            tag = next
        }
        return dict
    }

    /// Custom interrupt callbacks for the I/O layer.
    ///
    /// - demuxing: Set by the user before `openInput`.
    /// - muxing: Set by the user before `writeHeader` (mainly useful for `AVOutputFormat.Flag.noFile` formats).
    ///   The callback should also be passed to avio_open2() if it's used to open the file.
    public var interruptCallback: AVIOInterruptCallback {
        get { return cContext.interrupt_callback }
        set { cContextPtr.pointee.interrupt_callback = newValue }
    }

    /// The stream index for specified media type.
    ///
    /// - Parameter mediaType: media type
    /// - Returns: stream index if it exists
    public func streamIndex(for mediaType: AVMediaType) -> Int? {
        if let index = streams.index(where: { $0.codecParameters.mediaType == mediaType }) {
            return index
        }
        return nil
    }

    /// Print detailed information about the input or output format, such as duration, bitrate, streams,
    /// container, programs, metadata, side data, codec and time base.
    ///
    /// - Parameters isOutput: Select whether the specified context is an input(0) or output(1).
    public func dumpFormat(isOutput: Bool) {
        av_dump_format(cContextPtr, 0, url, isOutput ? 1 : 0)
    }

    deinit {
        avformat_close_input(&cContextPtr)
    }
}

// MARK: - Flag

extension AVFormatContext {

    /// Flags modifying the (de)muxer behaviour.
    public struct Flag: OptionSet {
        /// Generate missing pts even if it requires parsing future frames.
        public static let genPTS = Flag(rawValue: AVFMT_FLAG_GENPTS)
        /// Ignore index.
        public static let ignIdx = Flag(rawValue: AVFMT_FLAG_IGNIDX)
        /// Do not block when reading packets from input.
        public static let nonBlock = Flag(rawValue: AVFMT_FLAG_NONBLOCK)
        /// Ignore DTS on frames that contain both DTS & PTS.
        public static let ignDTS = Flag(rawValue: AVFMT_FLAG_IGNDTS)
        /// Do not infer any values from other values, just return what is stored in the container.
        public static let noFillIn = Flag(rawValue: AVFMT_FLAG_NOFILLIN)
        /// Do not use AVParsers, you also must set AVFMT_FLAG_NOFILLIN as the fillin code works on frames and
        /// no parsing -> no frames. Also seeking to frames can not work if parsing to find frame boundaries has
        /// been disabled.
        public static let noParse = Flag(rawValue: AVFMT_FLAG_NOPARSE)
        /// Do not buffer frames when possible.
        public static let noBuffer = Flag(rawValue: AVFMT_FLAG_NOBUFFER)
        /// The caller has supplied a custom AVIOContext, don't avio_close() it.
        public static let customIO = Flag(rawValue: AVFMT_FLAG_CUSTOM_IO)
        /// Discard frames marked corrupted.
        public static let discardCorrupt = Flag(rawValue: AVFMT_FLAG_DISCARD_CORRUPT)
        /// Flush the AVIOContext every packet.
        public static let flushPackets = Flag(rawValue: AVFMT_FLAG_FLUSH_PACKETS)
        /// When muxing, try to avoid writing any random/volatile data to the output.
        /// This includes any random IDs, real-time timestamps/dates, muxer version, etc.
        ///
        /// This flag is mainly intended for testing.
        public static let bitexact = Flag(rawValue: AVFMT_FLAG_BITEXACT)
        /// Try to interleave outputted packets by dts (using this flag can slow demuxing down).
        public static let sortDTS = Flag(rawValue: AVFMT_FLAG_SORT_DTS)
        /// Enable use of private Flag by delaying codec open (this could be made default once all code is converted).
        public static let privOpt = Flag(rawValue: AVFMT_FLAG_PRIV_OPT)
        /// Enable fast, but inaccurate seeks for some formats.
        public static let fastSeek = Flag(rawValue: AVFMT_FLAG_FAST_SEEK)
        /// Stop muxing when the shortest stream stops.
        public static let shortest = Flag(rawValue: AVFMT_FLAG_SHORTEST)
        /// Add bitstream filters as requested by the muxer.
        public static let autoBSF = Flag(rawValue: AVFMT_FLAG_AUTO_BSF)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension AVFormatContext.Flag: CustomStringConvertible {

    public var description: String {
        var str = "["
        if contains(.genPTS) { str += "genPTS, " }
        if contains(.ignIdx) { str += "ignIdx, " }
        if contains(.nonBlock) { str += "nonBlock, " }
        if contains(.ignDTS) { str += "ignDTS, " }
        if contains(.noFillIn) { str += "noFillIn, " }
        if contains(.noParse) { str += "noParse, " }
        if contains(.noBuffer) { str += "noBuffer, " }
        if contains(.customIO) { str += "customIO, " }
        if contains(.discardCorrupt) { str += "discardCorrupt, " }
        if contains(.flushPackets) { str += "flushPackets, " }
        if contains(.bitexact) { str += "bitexact, " }
        if contains(.sortDTS) { str += "sortDTS, " }
        if contains(.privOpt) { str += "privOpt, " }
        if contains(.fastSeek) { str += "fastSeek, " }
        if contains(.shortest) { str += "shortest, " }
        if contains(.autoBSF) { str += "autoBSF, " }
        if str.suffix(2) == ", " {
            str.removeLast(2)
        }
        str += "]"
        return str
    }
}

// MARK: - Demuxing

extension AVFormatContext {

    /// Open an input stream and read the header. The codecs are not opened.
    ///
    /// - Parameters:
    ///   - url: URL of the stream to open.
    ///   - format: If non-nil, this parameter forces a specific input format. Otherwise the format is autodetected.
    ///   - options: A dictionary filled with `AVFormatContext` and demuxer-private options.
    /// - Throws: AVError
    public convenience init(
        url: String,
        format: AVInputFormat? = nil,
        options: [String: String]? = nil
    ) throws {
        var pm: OpaquePointer? = options?.toAVDict()
        defer { av_dict_free(&pm) }

        var ctxPtr: UnsafeMutablePointer<CAVFormatContext>?
        try throwIfFail(avformat_open_input(&ctxPtr, url, format?.cFormatPtr, &pm))
        self.init(cContextPtr: ctxPtr!)

        dumpUnrecognizedOptions(pm)
    }

    /// The input container format.
    public var inputFormat: AVInputFormat? {
        get {
            if let fmtPtr = cContext.iformat {
                return AVInputFormat(cFormatPtr: fmtPtr)
            }
            return nil
        }
        set { cContextPtr.pointee.iformat = newValue?.cFormatPtr }
    }

    /// Position of the first frame of the component, in `avTimeBase` fractional seconds.
    /// Never set this value directly: It is deduced from the `AVStream` values.
    public var startTime: Int64 {
        return cContext.start_time
    }

    /// Duration of the stream, in `avTimeBase` fractional seconds. Only set this value if you know
    /// none of the individual stream durations and also do not set any of them.
    /// This is deduced from the AVStream values if not set.
    public var duration: Int64 {
        return cContext.duration
    }

    /// Total stream bitrate in bit/s, 0 if not available.
    /// Never set it directly if the file_size and the duration are known as FFmpeg can compute it automatically.
    public var bitRate: Int64 {
        return cContext.bit_rate
    }

    /// The size of the file.
    public var size: Int64 {
        if let pb = pb {
            return (try? pb.size()) ?? 0
        }
        return 0
    }

    /// Open an input stream and read the header.
    ///
    /// - Parameter url: URL of the stream to open.
    ///   - url: URL of the stream to open.
    ///   - format: If non-nil, this parameter forces a specific input format. Otherwise the format is autodetected.
    ///   - options: A dictionary filled with `AVFormatContext` and demuxer-private options.
    /// - Throws: AVError
    public func openInput(
        _ url: String,
        format: AVInputFormat? = nil,
        options: [String: String]? = nil
    ) throws {
        var pm: OpaquePointer? = options?.toAVDict()
        defer { av_dict_free(&pm) }

        try throwIfFail(avformat_open_input(&cContextPtr, url, format?.cFormatPtr, &pm))

        dumpUnrecognizedOptions(pm)
    }

    /// Read packets of a media file to get stream information.
    ///
    /// This is useful for file formats with no headers such as MPEG.
    /// This function also computes the real framerate in case of MPEG-2 repeat frame mode.
    /// The logical file position is not changed by this function; examined packets may be buffered
    /// for later processing.
    ///
    /// - Note: This function isn't guaranteed to open all the codecs, so options being non-empty at return
    ///   is a perfectly normal behavior.
    ///
    /// - Parameter options: If non-NULL, an `streamCount` long array of pointers to dictionaries,
    ///   where i-th member contains options for codec corresponding to i-th stream. On return each dictionary
    ///   will be filled with options that were not found.
    /// - Throws: AVError
    public func findStreamInfo(options: [[String: String]]? = nil) throws {
        if let options = options, !options.isEmpty {
            var pms = [OpaquePointer?](repeating: nil, count: streamCount)
            for (i, opt) in options.enumerated() where i < streamCount {
                pms[i] = opt.toAVDict()
            }
            try throwIfFail(avformat_find_stream_info(cContextPtr, &pms))
            pms.forEach { pm in
                var pm = pm
                dumpUnrecognizedOptions(pm)
                av_dict_free(&pm)
            }
        } else {
            try throwIfFail(avformat_find_stream_info(cContextPtr, nil))
        }
    }

    /// Find the "best" stream in the file.
    ///
    /// - Parameters:
    ///   - type: stream type
    ///   - wantedStreamIndex: user-requested stream index, or -1 for automatic selection
    ///   - relatedStreamIndex: try to find a stream related (eg. in the same program) to this one, or -1 if none
    /// - Returns: stream index
    /// - Throws: AVError
    public func findBestStream(
        type: AVMediaType,
        wantedStreamIndex: Int = -1,
        relatedStreamIndex: Int = -1
    ) throws -> Int {
        let ret = av_find_best_stream(cContextPtr, type, Int32(wantedStreamIndex), Int32(relatedStreamIndex), nil, 0)
        try throwIfFail(ret)
        return Int(ret)
    }

    /// Guess the sample aspect ratio of a frame, based on both the stream and the frame aspect ratio.
    ///
    /// Since the frame aspect ratio is set by the codec but the stream aspect ratio is set by the demuxer,
    /// these two may not be equal. This function tries to return the value that you should use if you would
    /// like to display the frame.
    ///
    /// Basic logic is to use the stream aspect ratio if it is set to something sane otherwise use the frame
    /// aspect ratio. This way a container setting, which is usually easy to modify can override the coded value
    /// in the frames.
    ///
    /// - Parameters:
    ///   - stream: the stream which the frame is part of
    ///   - frame: the frame with the aspect ratio to be determined
    /// - Returns: the guessed (valid) sample_aspect_ratio, 0/1 if no idea
    public func guessSampleAspectRatio(stream: AVStream?, frame: AVFrame?) -> AVRational {
        return av_guess_sample_aspect_ratio(cContextPtr, stream?.cStreamPtr, frame?.cFramePtr)
    }

    /// Return the next frame of a stream.
    ///
    /// This function returns what is stored in the file, and does not validate that what is there are valid frames
    /// for the decoder. It will split what is stored in the file into frames and return one for each call. It will
    /// not omit invalid data between valid frames so as to give the decoder the maximum information possible for
    /// decoding.
    ///
    /// - Parameter packet: the packet used to store data
    /// - Throws: AVError
    public func readFrame(into packet: AVPacket) throws {
        try throwIfFail(av_read_frame(cContextPtr, packet.cPacketPtr))
    }

    /// Seek to the keyframe at timestamp.
    ///
    /// - Parameters:
    ///   - streamIndex: If stream_index is `-1`, a default stream is selected, and timestamp is automatically
    ///     converted from `avTimeBase` units to the stream specific time_base.
    ///   - timestamp: Timestamp in AVStream.time_base units or, if no stream is specified, in `avTimeBase` units.
    ///   - flags: flags which select direction and seeking mode
    /// - Throws: AVError
    public func seekFrame(streamIndex: Int, timestamp: Int64, flags: SeekFlag) throws {
        try throwIfFail(av_seek_frame(cContextPtr, Int32(streamIndex), timestamp, flags.rawValue))
    }

    /// Discard all internally buffered data. This can be useful when dealing with
    /// discontinuities in the byte stream. Generally works only with formats that
    /// can resync. This includes headerless formats like MPEG-TS/TS but should also
    /// work with NUT, Ogg and in a limited way AVI for example.
    ///
    /// The set of streams, the detected duration, stream parameters and codecs do
    /// not change when calling this function. If you want a complete reset, it's
    /// better to open a new AVFormatContext.
    ///
    /// This does not flush the AVIOContext (s->pb). If necessary, call
    /// avio_flush(s->pb) before calling this function.
    public func flush() {
        avformat_flush(cContextPtr)
    }

    /// Start playing a network-based stream (e.g. RTSP stream) at the current position.
    ///
    /// - Throws: AVError
    public func readPlay() throws {
        try throwIfFail(av_read_play(cContextPtr))
    }

    /// Pause a network-based stream (e.g. RTSP stream).
    ///
    /// Use `readPlay` to resume it.
    ///
    /// - Throws: AVError
    public func readPause() throws {
        try throwIfFail(av_read_pause(cContextPtr))
    }
}

extension AVFormatContext {

    public struct SeekFlag {
        /// seek backward
        public static let backward = SeekFlag(rawValue: AVSEEK_FLAG_BACKWARD)
        /// seeking based on position in bytes
        public static let byte = SeekFlag(rawValue: AVSEEK_FLAG_BYTE)
        /// seek to any frame, even non-keyframes
        public static let any = SeekFlag(rawValue: AVSEEK_FLAG_ANY)
        /// seeking based on frame number
        public static let frame = SeekFlag(rawValue: AVSEEK_FLAG_FRAME)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Muxing

extension AVFormatContext {

    /// Allocate an `AVFormatContext` for an output format.
    ///
    /// - Parameters:
    ///   - format: format to use for allocating the context, if `nil` formatName and filename are used instead
    ///   - formatName: the name of output format to use for allocating the context, if `nil` filename is used instead
    ///   - filename: the name of the filename to use for allocating the context, may be `nil`
    /// - Throws: AVError
    public convenience init(
        format: AVOutputFormat?,
        formatName: String? = nil,
        filename: String? = nil
    ) throws {
        var ctxPtr: UnsafeMutablePointer<CAVFormatContext>?
        try throwIfFail(avformat_alloc_output_context2(&ctxPtr, format?.cFormatPtr, formatName, filename))
        self.init(cContextPtr: ctxPtr!)
    }

    /// The output container format.
    public var outputFormat: AVOutputFormat? {
        get {
            if let fmtPtr = cContext.oformat {
                return AVOutputFormat(cFormatPtr: fmtPtr)
            }
            return nil
        }
        set { cContextPtr.pointee.oformat = newValue?.cFormatPtr }
    }

    /// Create and initialize a `AVIOContext` for accessing the resource indicated by url.
    ///
    /// - Parameters:
    ///   - url: resource to access
    ///   - flags: flags which control how the resource indicated by url is to be opened
    /// - Throws: AVError
    public func openIO(url: String, flags: AVIOContext.Flag) throws {
        pb = try AVIOContext(url: url, flags: flags)
    }

    /// Add a new stream to a media file.
    ///
    /// - Parameter codec: If non-nil, the `AVCodecContext` corresponding to the new stream will be initialized
    ///   to use this codec. This is needed for e.g. codec-specific defaults to be set, so codec should be
    ///   provided if it is known.
    /// - Returns: newly created stream or `nil` on error.
    public func addStream(codec: AVCodec? = nil) -> AVStream? {
        if let streamPtr = avformat_new_stream(cContextPtr, codec?.cCodecPtr) {
            return AVStream(cStreamPtr: streamPtr)
        }
        return nil
    }

    /// Allocate the stream private data and write the stream header to an output media file.
    ///
    /// - Note: The `outputFormat` field must be set to the desired output format;
    ///   The `pb` field must be set to an already opened `AVIOContext`.
    ///
    /// - Parameter options: the `AVFormatContext` and muxer-private options.
    /// - Throws: AVError
    public func writeHeader(options: [String: String]? = nil) throws {
        var pm: OpaquePointer? = options?.toAVDict()
        defer { av_dict_free(&pm) }

        try throwIfFail(avformat_write_header(cContextPtr, &pm))

        dumpUnrecognizedOptions(pm)
    }

    /// Write a packet to an output media file.
    ///
    /// This function passes the packet directly to the muxer, without any buffering or reordering.
    /// The caller is responsible for correctly interleaving the packets if the format requires it.
    /// Callers that want libavformat to handle the interleaving should call `interleavedWriteFrame`
    /// instead of this function.
    ///
    /// - Parameter pkt: The packet containing the data to be written. Note that unlike
    ///   `interleavedWriteFrame`, this function does not take ownership of the packet passed to it
    ///   (though some muxers may make an internal reference to the input packet).
    ///
    ///   This parameter can be nil (at any time, not just at the end), in order to immediately flush
    ///   data buffered within the muxer, for muxers that buffer up data internally before writing it
    ///   to the output.
    ///
    ///   Packet's `streamIndex` field must be set to the index of the corresponding stream in `streams`.
    ///
    ///   The timestamps (`AVPacket.pts`, `AVPacket.dts`) must be set to correct values in the stream's
    ///   timebase (unless the output format is flagged with the `AVOutputFormat.Flag.noTimestamps` flag,
    ///   then they can be set to `avNoPTS`).
    ///   The dts for subsequent packets passed to this function must be strictly increasing when compared
    ///   in their respective timebases (unless the output format is flagged with the
    ///   `AVOutputFormat.Flag.tsNonstrict`, then they merely have to be nondecreasing).
    ///   `AVPacket.duration` should also be set if known.
    /// - Throws: AVError
    public func writeFrame(_ pkt: AVPacket?) throws {
        try throwIfFail(av_write_frame(cContextPtr, pkt?.cPacketPtr))
    }

    /// Write a packet to an output media file ensuring correct interleaving.
    ///
    /// This function will buffer the packets internally as needed to make sure the packets in the output file
    /// are properly interleaved in the order of increasing dts.
    /// Callers doing their own interleaving should call `writeFrame` instead of this function.
    ///
    /// Using this function instead of `writeFrame` can give muxers advance knowledge of future packets,
    /// improving e.g. the behaviour of the mp4 muxer for VFR content in fragmenting mode.
    ///
    /// - Parameter pkt: The packet containing the data to be written.
    ///
    ///   If the packet is reference-counted, this function will take ownership of this reference and unreference
    ///   it later when it sees fit.
    ///   The caller must not access the data through this reference after this function returns. If the packet
    ///   is not reference-counted, libavformat will make a copy.
    ///
    ///   This parameter can be nil (at any time, not just at the end), to flush the interleaving queues.
    ///
    ///   Packet's `streamIndex` field must be set to the index of the corresponding stream in `streams`.
    ///
    ///   The timestamps (`AVPacket.pts`, `AVPacket.dts`) must be set to correct values in the stream's timebase
    ///   (unless the output format is flagged with the `AVOutputFormat.Flag.noTimestamps` flag, then they can be
    ///   set to `avNoPTS`).
    ///   The dts for subsequent packets in one stream must be strictly increasing (unless the output format is
    ///   flagged with the `AVOutputFormat.Flag.tsNonstrict`, then they merely have to be nondecreasing).
    ///  `AVPacket.duration` should also be set if known.
    /// - Throws: AVError
    /// - SeeAlso: writeFrame
    public func interleavedWriteFrame(_ pkt: AVPacket?) throws {
        try throwIfFail(av_interleaved_write_frame(cContextPtr, pkt?.cPacketPtr))
    }

    /// Write the stream trailer to an output media file and free the file private data.
    ///
    /// May only be called after a successful call to `writeHeader`.
    ///
    /// - Throws: AVError
    public func writeTrailer() throws {
        try throwIfFail(av_write_trailer(cContextPtr))
    }
}

extension AVFormatContext: AVOptionAccessor {

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        return try body(cContextPtr)
    }
}
