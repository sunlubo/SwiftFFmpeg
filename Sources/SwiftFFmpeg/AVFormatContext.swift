//
//  AVFormatContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVFormatContext

typealias CAVFormatContext = CFFmpeg.AVFormatContext

/// Format I/O context.
public final class AVFormatContext {
  var native: UnsafeMutablePointer<CAVFormatContext>!
  var ioContext: AVIOContext?

  /// Create an `AVFormatContext`.
  public init() {
    self.native = avformat_alloc_context()
  }

  /// Open an input stream and read the header. The codecs are not opened.
  ///
  /// - Parameters:
  ///   - url: URL of the stream to open.
  ///   - format: If non-nil, this parameter forces a specific input format. Otherwise the format is autodetected.
  ///   - options: A dictionary filled with `AVFormatContext` and demuxer-private options.
  /// - Throws: AVError
  public init(
    url: String,
    format: AVInputFormat? = nil,
    options: [String: String]? = nil
  ) throws {
    var pm: OpaquePointer? = options?.avDict
    defer { av_dict_free(&pm) }

    try throwIfFail(avformat_open_input(&native, url, format?.native, &pm))

    dumpUnrecognizedOptions(pm)
  }

  /// Allocate an `AVFormatContext` for an output format.
  ///
  /// - Parameters:
  ///   - format: the format to use for allocating the context, if `nil` formatName and filename are used instead
  ///   - formatName: the name of output format to use for allocating the context, if `nil` filename is used instead
  ///   - filename: the name of the filename to use for allocating the context, may be `nil`
  /// - Throws: AVError
  public init(
    format: AVOutputFormat?,
    formatName: String? = nil,
    filename: String? = nil
  ) throws {
    try throwIfFail(
      avformat_alloc_output_context2(&native, format?.native, formatName, filename))
  }

  deinit {
    avformat_close_input(&native)
  }

  /// Input or output URL.
  ///
  /// - demuxing: Set by `openInput(_ url:format:options:)`, initialized to an empty string
  ///   if `url` parameter was `nil` in `openInput(_ url:format:options:)`.
  /// - muxing: May be set by the caller before calling `writeHeader(options:)` to a string.
  ///   Set to an empty string if it was `nil` in `writeHeader(options:)`.
  public var url: String? {
    get { String(cString: native.pointee.url) }
    set { native.pointee.url = av_strdup(newValue) }
  }

  /// I/O context.
  ///
  /// - demuxing: Either set by the user before `openInput(_ url:format:options:)` (then the user must close it manually)
  ///   or set by `openInput(_ url:format:options:)`.
  /// - muxing: Set by the user before `writeHeader(options:)`. The caller must take care of closing the IO context.
  public var pb: AVIOContext? {
    get { native.pointee.pb.map(AVIOContext.init(native:)) }
    set {
      ioContext = newValue
      return native.pointee.pb = newValue?.native
    }
  }

  /// The number of streams in the file.
  public var streamCount: Int {
    Int(native.pointee.nb_streams)
  }

  /// The duration field can be estimated through various ways, and this field can be used
  /// to know how the duration was estimated.
  ///
  /// - encoding: unused
  /// - decoding: Read by user
  public var durationEstimationMethod: AVDurationEstimationMethod {
    AVDurationEstimationMethod(rawValue: native.pointee.duration_estimation_method)
  }

  /// A list of all streams in the file. New streams are created with `addStream(codec:)`.
  ///
  /// - demuxing: Streams are created by libavformat in `openInput(_ url:format:options:)`.
  ///   If `AVFMTCTX_NOHEADER` is set in `ctx_flags`, then new streams may also appear in `readFrame(into:)`.
  /// - muxing: Streams are created by the user before `writeHeader(options:)`.
  public var streams: [AVStream] {
    var list = [AVStream]()
    for i in 0 ..< streamCount {
      let stream = native.pointee.streams.advanced(by: i).pointee!
      list.append(AVStream(native: stream))
    }
    return list
  }

  /// The flags used to modify the (de)muxer behaviour.
  ///
  /// - demuxing: Set by the caller before `openInput(_ url:format:options:)`.
  /// - muxing: Set by the caller before `writeHeader(options:)`.
  public var flags: Flag {
    get { Flag(rawValue: native.pointee.flags) }
    set { native.pointee.flags = newValue.rawValue }
  }

  /// Maximum size of the data read from input for determining the input container format.
  ///
  /// Demuxing only, set by the caller before avformat_open_input().
  public var probeSize: Int64 {
    get { native.pointee.probesize }
    set { native.pointee.probesize = newValue }
  }

  /// When muxing, chapters are normally written in the file header,
  /// so nb_chapters should normally be initialized before `writeHeader`
  /// is called. Some muxers (e.g. mov and mkv) can also write chapters
  /// in the trailer. To write chapters in the trailer, nb_chapters
  /// must be zero when `writeHeader` is called and non-zero when
  /// `writeTrailer` is called.
  ///
  /// - muxing: set by user
  /// - demuxing: set by libavformat
  public var chapters: [AVChapter] {
    get {
      var list = [AVChapter]()
      for i in 0 ..< native.pointee.nb_chapters {
        let chapter = native.pointee.chapters.advanced(by: Int(i)).pointee!
        list.append(AVChapter(native: chapter))
      }
      return list
    }
    set {
      let cchapters = UnsafeMutablePointer<UnsafeMutablePointer<CAVChapter>?>.allocate(
        capacity: newValue.count
      )
      for (index, chapter) in newValue.enumerated() {
        let cchapter = UnsafeMutablePointer<CAVChapter>.allocate(capacity: 1)
        cchapter.initialize(to: chapter.native)
        cchapters.advanced(by: index).pointee = cchapter
      }
      native.pointee.chapters = cchapters
      native.pointee.nb_chapters = UInt32(newValue.count)
    }
  }

  /// Metadata that applies to the whole file.
  ///
  /// - demuxing: Set by libavformat in `openInput(_ url:format:options:)`.
  /// - muxing: May be set by the caller before `writeHeader(options:)`.
  public var metadata: [String: String] {
    get {
      var dict = [String: String]()
      var prev: UnsafeMutablePointer<AVDictionaryEntry>?
      while let tag = av_dict_get(native.pointee.metadata, "", prev, AV_DICT_IGNORE_SUFFIX) {
        dict[String(cString: tag.pointee.key)] = String(cString: tag.pointee.value)
        prev = tag
      }
      return dict
    }
    set { native.pointee.metadata = newValue.avDict }
  }

  /// Custom interrupt callbacks for the I/O layer.
  ///
  /// - demuxing: Set by the user before `openInput(_ url:format:options:)`.
  /// - muxing: Set by the user before `writeHeader(options:)` (mainly useful for `AVOutputFormat.Flag.noFile` formats).
  ///   The callback should also be passed to `avio_open2()` if it's used to open the file.
  public var interruptCallback: AVIOInterruptCallback {
    get { native.pointee.interrupt_callback }
    set { native.pointee.interrupt_callback = newValue }
  }

  /// Print detailed information about the input or output format, such as duration, bitrate, tracks,
  /// container, programs, metadata, side data, codec and timebase.
  ///
  /// - Parameters:
  ///   - url: the URL to print, such as source or destination file
  ///   - isOutput: Select whether the specified context is an input(false) or output(true).
  public func dumpFormat(url: String? = nil, isOutput: Bool = false) {
    av_dump_format(native, 0, url ?? self.url, isOutput ? 1 : 0)
  }
}

// MARK: - AVDurationEstimationMethod

public struct AVDurationEstimationMethod: Equatable {
  /// Duration accurately estimated from PTSes
  public static let fromPTS = AVDurationEstimationMethod(rawValue: AVFMT_DURATION_FROM_PTS)

  /// Duration estimated from a stream with a known duration
  public static let fromStream = AVDurationEstimationMethod(rawValue: AVFMT_DURATION_FROM_STREAM)

  /// Duration estimated from bitrate (less accurate)
  public static let fromBitrate = AVDurationEstimationMethod(rawValue: AVFMT_DURATION_FROM_BITRATE)

  public let rawValue: CFFmpeg.AVDurationEstimationMethod
  public init(rawValue: CFFmpeg.AVDurationEstimationMethod) { self.rawValue = rawValue }
}

// MARK: - AVFormatContext.Flag

extension AVFormatContext {
  /// Flags used to modify the (de)muxer behaviour.
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
    /// Do not use AVParsers, you also must set `noFillIn` as the fillin code works on frames and
    /// no parsing -> no frames. Also seeking to frames can not work if parsing to find frame boundaries has
    /// been disabled.
    public static let noParse = Flag(rawValue: AVFMT_FLAG_NOPARSE)
    /// Do not buffer frames when possible.
    public static let noBuffer = Flag(rawValue: AVFMT_FLAG_NOBUFFER)
    /// The caller has supplied a custom AVIOContext, don't avio_close() it.
    public static let customIO = Flag(rawValue: AVFMT_FLAG_CUSTOM_IO)
    /// Discard frames marked corrupted.
    public static let discardCorrupt = Flag(rawValue: AVFMT_FLAG_DISCARD_CORRUPT)
    /// Flush the `AVIOContext` every packet.
    public static let flushPackets = Flag(rawValue: AVFMT_FLAG_FLUSH_PACKETS)
    /// When muxing, try to avoid writing any random/volatile data to the output.
    /// This includes any random IDs, real-time timestamps/dates, muxer version, etc.
    ///
    /// This flag is mainly intended for testing.
    public static let bitexact = Flag(rawValue: AVFMT_FLAG_BITEXACT)
    /// Try to interleave outputted packets by dts (using this flag can slow demuxing down).
    public static let sortDTS = Flag(rawValue: AVFMT_FLAG_SORT_DTS)
    /// Enable fast, but inaccurate seeks for some formats.
    public static let fastSeek = Flag(rawValue: AVFMT_FLAG_FAST_SEEK)
    /// Stop muxing when the shortest stream stops.
    public static let shortest = Flag(rawValue: AVFMT_FLAG_SHORTEST)
    /// Add bitstream filters as requested by the muxer.
    public static let autoBSF = Flag(rawValue: AVFMT_FLAG_AUTO_BSF)

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
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
  /// The input container format.
  public var inputFormat: AVInputFormat? {
    get { native.pointee.iformat.map(AVInputFormat.init(native:)) }
    set { native.pointee.iformat = newValue?.native }
  }

  /// Position of the first frame of the component, in `AVTimestamp.timebase` fractional seconds.
  public var startTime: Int64 {
    native.pointee.start_time
  }

  /// Duration of the stream, in `AVTimestamp.timebase` fractional seconds.
  public var duration: Int64 {
    native.pointee.duration
  }

  /// Total stream bitrate in bit/s, 0 if not available.
  public var bitRate: Int64 {
    native.pointee.bit_rate
  }

  /// The size of the file.
  public var size: Int64 {
    (try? pb?.size()) ?? 0
  }

  /// Open an input stream and read the header.
  ///
  /// - Parameter url: URL of the stream to open.
  ///   - url: URL of the stream to open.
  ///   - format: If non-nil, this parameter forces a specific input format. Otherwise the format is autodetected.
  ///   - options: A dictionary filled with `AVFormatContext` and demuxer-private options.
  /// - Throws: AVError
  public func openInput(
    _ url: String? = nil,
    format: AVInputFormat? = nil,
    options: [String: String]? = nil
  ) throws {
    var pm: OpaquePointer? = options?.avDict
    defer { av_dict_free(&pm) }

    try throwIfFail(avformat_open_input(&native, url, format?.native, &pm))

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
        pms[i] = opt.avDict
      }
      try throwIfFail(avformat_find_stream_info(native, &pms))
      pms.forEach { pm in
        var pm = pm
        dumpUnrecognizedOptions(pm)
        av_dict_free(&pm)
      }
    } else {
      try throwIfFail(avformat_find_stream_info(native, nil))
    }
  }

  /// Find the "best" stream in the file.
  ///
  /// - Parameters:
  ///   - type: stream type
  ///   - wantedStreamIndex: user-requested stream index, or -1 for automatic selection
  ///   - relatedStreamIndex: try to find a stream related (eg. in the same program) to this one, or -1 if none
  /// - Returns: stream index if it exists
  public func findBestStream(
    type: AVMediaType,
    wantedStreamIndex: Int = -1,
    relatedStreamIndex: Int = -1
  ) -> Int? {
    let ret = av_find_best_stream(
      native, type.native, Int32(wantedStreamIndex), Int32(relatedStreamIndex), nil, 0
    )
    return ret >= 0 ? Int(ret) : nil
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
  /// - Returns: the guessed (valid) sample aspect ratio, 0/1 if no idea
  public func guessSampleAspectRatio(stream: AVStream?, frame: AVFrame? = nil) -> AVRational {
    av_guess_sample_aspect_ratio(native, stream?.native, frame?.native)
  }

  /// Guess the frame rate, based on both the container and codec information.
  ///
  /// - Parameters:
  ///   - stream: the stream which the frame is part of
  ///   - frame: the frame for which the frame rate should be determined
  /// - Returns: the guessed (valid) frame rate, 0/1 if no idea
  public func guessFrameRate(stream: AVStream, frame: AVFrame? = nil) -> AVRational {
    av_guess_frame_rate(native, stream.native, frame?.native)
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
    try throwIfFail(av_read_frame(native, packet.native))
  }

  /// Seek to the keyframe at timestamp.
  ///
  /// - Parameters:
  ///   - timestamp: Timestamp in `AVStream.timebase` units or, if no stream is specified,
  ///     in `AVTimestamp.timebase` units.
  ///   - trackIndex: If `trackIndex` is -1, a default stream is selected, and timestamp
  ///     is automatically converted from `AVTimestamp.timebase` units to the stream specific timebase.
  ///   - flags: flags which select direction and seeking mode
  /// - Throws: AVError
  public func seekFrame(to timestamp: Int64, streamIndex: Int, flags: SeekFlag) throws {
    try throwIfFail(av_seek_frame(native, Int32(streamIndex), timestamp, flags.rawValue))
  }

  /// Discard all internally buffered data. This can be useful when dealing with
  /// discontinuities in the byte stream. Generally works only with formats that
  /// can resync. This includes headerless formats like MPEG-TS/TS but should also
  /// work with NUT, Ogg and in a limited way AVI for example.
  ///
  /// The set of tracks, the detected duration, stream parameters and codecs do
  /// not change when calling this function. If you want a complete reset, it's
  /// better to open a new `AVFormatContext`.
  ///
  /// This does not flush the `AVIOContext` (`pb`). If necessary, call `pb.flush`
  /// before calling this function.
  public func flush() {
    avformat_flush(native)
  }

  /// Start playing a network-based stream (e.g. RTSP stream) at the current position.
  ///
  /// - Throws: AVError
  public func play() throws {
    try throwIfFail(av_read_play(native))
  }

  /// Pause a network-based stream (e.g. RTSP stream).
  ///
  /// Use `play` to resume it.
  ///
  /// - Throws: AVError
  public func pause() throws {
    try throwIfFail(av_read_pause(native))
  }
}

// MARK: - AVFormatContext.SeekFlag

extension AVFormatContext {
  public struct SeekFlag: OptionSet {
    /// seek backward
    public static let backward = SeekFlag(rawValue: AVSEEK_FLAG_BACKWARD)
    /// seeking based on position in bytes
    public static let byte = SeekFlag(rawValue: AVSEEK_FLAG_BYTE)
    /// seek to any frame, even non-keyframes
    public static let any = SeekFlag(rawValue: AVSEEK_FLAG_ANY)
    /// seeking based on frame number
    public static let frame = SeekFlag(rawValue: AVSEEK_FLAG_FRAME)

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
  }
}

// MARK: - Muxing

extension AVFormatContext {
  /// The output container format.
  public var outputFormat: AVOutputFormat? {
    get { native.pointee.oformat.map(AVOutputFormat.init(native:)) }
    set { native.pointee.oformat = newValue?.native }
  }

  /// Create and initialize a `AVIOContext` for accessing the resource indicated by url.
  ///
  /// - Parameters:
  ///   - url: resource to access
  ///   - flags: flags which control how the resource indicated by url is to be opened
  /// - Throws: AVError
  public func openOutput(url: String, flags: AVIOContext.Flag) throws {
    pb = try AVIOContext(url: url, flags: flags)
  }

  /// Add a new stream to a media file.
  ///
  /// - Parameter codec: If non-nil, the `AVCodecContext` corresponding to the new stream will be
  ///   initialized to use this codec. This is needed for e.g. codec-specific defaults to be set,
  ///   so codec should be provided if it is known.
  /// - Returns: newly created stream or `nil` on error.
  public func addStream(codec: AVCodec? = nil) -> AVStream? {
    avformat_new_stream(native, codec?.native).map(AVStream.init(native:))
  }

  /// Allocate the stream private data and write the stream header to an output media file.
  ///
  /// - Note: The `outputFormat` field must be set to the desired output format;
  ///   The `pb` field must be set to an already opened `AVIOContext`.
  ///
  /// - Parameter options: the `AVFormatContext` and muxer-private options
  /// - Throws: AVError
  public func writeHeader(options: [String: String]? = nil) throws {
    var pm = options?.avDict
    defer { av_dict_free(&pm) }

    try throwIfFail(avformat_write_header(native, &pm))

    dumpUnrecognizedOptions(pm)
  }

  /// Write a packet to an output media file.
  ///
  /// This function passes the packet directly to the muxer, without any buffering or reordering.
  /// The caller is responsible for correctly interleaving the packets if the format requires it.
  /// Callers that want libavformat to handle the interleaving should call
  /// `AVFormatContext.interleavedWriteFrame(_:)` instead of this function.
  ///
  /// - Parameter pkt: The packet containing the data to be written. Note that unlike
  ///   `AVFormatContext.interleavedWriteFrame(_:)`, this function does not take ownership of the
  ///   packet passed to it (though some muxers may make an internal reference to the input packet).
  ///
  ///   This parameter can be `nil` (at any time, not just at the end), in order to immediately flush
  ///   data buffered within the muxer, for muxers that buffer up data internally before writing it
  ///   to the output.
  ///
  ///   Packet's `AVPacket.trackIndex` field must be set to the index of the corresponding stream in
  ///   `tracks`.
  ///
  ///   The timestamps (`AVPacket.pts`, `AVPacket.dts`) must be set to correct values in the stream's
  ///   timebase (unless the output format is flagged with the `AVOutputFormat.Flag.noTimestamps` flag,
  ///   then they can be set to `AVTimestamp.noPTS`).
  ///   The dts for subsequent packets passed to this function must be strictly increasing when compared
  ///   in their respective timebases (unless the output format is flagged with the
  ///   `AVOutputFormat.Flag.tsNonstrict`, then they merely have to be nondecreasing).
  ///   `AVPacket.duration` should also be set if known.
  /// - Throws: AVError
  public func writeFrame(_ pkt: AVPacket?) throws {
    try throwIfFail(av_write_frame(native, pkt?.native))
  }

  /// Write a packet to an output media file ensuring correct interleaving.
  ///
  /// This function will buffer the packets internally as needed to make sure the packets in the output file
  /// are properly interleaved in the order of increasing dts.
  /// Callers doing their own interleaving should call `AVFormatContext.writeFrame(_:)` instead of this function.
  ///
  /// Using this function instead of `AVFormatContext.writeFrame(_:)` can give muxers advance knowledge of
  /// future packets, improving e.g. the behaviour of the mp4 muxer for VFR content in fragmenting mode.
  ///
  /// - Parameter pkt: The packet containing the data to be written.
  ///
  ///   If the packet is reference-counted, this function will take ownership of this reference and
  ///   unreference it later when it sees fit.
  ///   The caller must not access the data through this reference after this function returns.
  ///   If the packet is not reference-counted, libavformat will make a copy.
  ///
  ///   This parameter can be `nil` (at any time, not just at the end), to flush the interleaving queues.
  ///
  ///   Packet's `AVPacket.trackIndex` field must be set to the index of the corresponding stream in `tracks`.
  ///
  ///   The timestamps (`AVPacket.pts`, `AVPacket.dts`) must be set to correct values in the stream's timebase
  ///   (unless the output format is flagged with the `AVOutputFormat.Flag.noTimestamps` flag, then they can be
  ///   set to `AVTimestamp.noPTS`).
  ///   The dts for subsequent packets in one stream must be strictly increasing (unless the output format is
  ///   flagged with the `AVOutputFormat.Flag.tsNonstrict`, then they merely have to be nondecreasing).
  ///  `AVPacket.duration` should also be set if known.
  /// - Throws: AVError
  /// - SeeAlso: writeFrame
  public func interleavedWriteFrame(_ pkt: AVPacket?) throws {
    try throwIfFail(av_interleaved_write_frame(native, pkt?.native))
  }

  /// Write the stream trailer to an output media file and free the file private data.
  ///
  /// May only be called after a successful call to `writeHeader(options:)`.
  ///
  /// - Throws: AVError
  public func writeTrailer() throws {
    try throwIfFail(av_write_trailer(native))
  }
}

extension AVFormatContext: AVClassSupport, AVOptionSupport {
  public static let `class` = AVClass(native: avformat_get_class())

  public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
    try body(native)
  }
}
