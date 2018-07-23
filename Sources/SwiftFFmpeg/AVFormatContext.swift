//
//  AVFormatContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - Input Format

internal typealias CAVInputFormat = CFFmpeg.AVInputFormat

public struct AVInputFormat {
    internal let fmtPtr: UnsafeMutablePointer<CAVInputFormat>
    internal var fmt: CAVInputFormat { return fmtPtr.pointee }

    internal init(fmtPtr: UnsafeMutablePointer<CAVInputFormat>) {
        self.fmtPtr = fmtPtr
    }

    /// Find `AVInputFormat` based on the short name of the input format.
    ///
    /// - Parameter name: name of the input format
    public init?(name: String) {
        guard let fmtPtr = av_find_input_format(name) else {
            return nil
        }
        self.init(fmtPtr: fmtPtr)
    }

    /// A comma separated list of short names for the format.
    public var name: String {
        return String(cString: fmt.name)
    }

    /// Descriptive name for the format, meant to be more human-readable than name.
    public var longName: String {
        return String(cString: fmt.long_name)
    }

    /// If extensions are defined, then no probe is done. You should usually not use extension format guessing because
    /// it is not reliable enough.
    public var extensions: String? {
        if let strBytes = fmt.extensions {
            return String(cString: strBytes)
        }
        return nil
    }

    /// Comma-separated list of mime types.
    ///
    /// It is used check for matching mime types while probing.
    public var mimeType: String? {
        if let strBytes = fmt.mime_type {
            return String(cString: strBytes)
        }
        return nil
    }

    /// Get all registered demuxers.
    public static var all: [AVInputFormat] {
        var list = [AVInputFormat]()
        var state: UnsafeMutableRawPointer?
        while let fmt = av_demuxer_iterate(&state) {
            list.append(AVInputFormat(fmtPtr: UnsafeMutablePointer(mutating: fmt)))
        }
        return list
    }
}

// MARK: - Output Format

internal typealias CAVOutputFormat = CFFmpeg.AVOutputFormat

public struct AVOutputFormat {
    internal let fmtPtr: UnsafeMutablePointer<CAVOutputFormat>
    internal var fmt: CAVOutputFormat { return fmtPtr.pointee }

    internal init(fmtPtr: UnsafeMutablePointer<CAVOutputFormat>) {
        self.fmtPtr = fmtPtr
    }

    /// A comma separated list of short names for the format.
    public var name: String {
        return String(cString: fmt.name)
    }

    /// Descriptive name for the format, meant to be more human-readable than name.
    public var longName: String {
        return String(cString: fmt.long_name)
    }

    /// If extensions are defined, then no probe is done. You should usually not use extension format guessing because
    /// it is not reliable enough.
    public var extensions: String? {
        if let strBytes = fmt.extensions {
            return String(cString: strBytes)
        }
        return nil
    }

    /// Comma-separated list of mime types.
    ///
    /// It is used check for matching mime types while probing.
    public var mimeType: String? {
        if let strBytes = fmt.mime_type {
            return String(cString: strBytes)
        }
        return nil
    }

    /// default audio codec
    public var audioCodec: AVCodecID {
        return fmt.audio_codec
    }

    /// default video codec
    public var videoCodec: AVCodecID {
        return fmt.video_codec
    }

    /// default subtitle codec
    public var subtitleCodec: AVCodecID {
        return fmt.subtitle_codec
    }

    /// - SeeAlso: `AVFmtFlag`
    public var flags: Int32 {
        get { return fmt.flags }
        set { fmtPtr.pointee.flags = newValue }
    }

    /// Get all registered muxers.
    public static var all: [AVOutputFormat] {
        var list = [AVOutputFormat]()
        var state: UnsafeMutableRawPointer?
        while let fmt = av_muxer_iterate(&state) {
            list.append(AVOutputFormat(fmtPtr: UnsafeMutablePointer(mutating: fmt)))
        }
        return list
    }
}

internal typealias CAVFormatContext = CFFmpeg.AVFormatContext

/// Format I/O context.
public final class AVFormatContext {
    internal let ctxPtr: UnsafeMutablePointer<CAVFormatContext>
    internal var ctx: CAVFormatContext { return ctxPtr.pointee }

    private var isOpened = false

    /// Allocate an `AVFormatContext`.
    public init() {
        self.ctxPtr = avformat_alloc_context()
    }

    /// Open an input stream and read the header. The codecs are not opened.
    ///
    /// - Parameters:
    ///   - url: URL of the stream to open.
    ///   - fmt: If non-nil, this parameter forces a specific input format. Otherwise the format is autodetected.
    ///   - options: A dictionary filled with `AVFormatContext` and demuxer-private options.
    /// - Throws: AVError
    public init(url: String, fmt: AVInputFormat?, options: [String: String]? = nil) throws {
        var pm: OpaquePointer?
        defer { av_dict_free(&pm) }
        if let options = options {
            for (k, v) in options {
                av_dict_set(&pm, k, v, 0)
            }
        }

        var ctxPtr: UnsafeMutablePointer<CAVFormatContext>?
        try throwIfFail(avformat_open_input(&ctxPtr, url, fmt?.fmtPtr, &pm))
        self.ctxPtr = ctxPtr!
        self.isOpened = true

        dumpUnrecognizedOptions(pm)
    }

    /// Allocate an `AVFormatContext` for an output format.
    ///
    /// - Parameters:
    ///   - fmt: format to use for allocating the context, if nil format_name and filename are used instead
    ///   - formatName: the name of output format to use for allocating the context, if nil filename is used instead
    ///   - filename: the name of the filename to use for allocating the context, may be nil
    /// - Throws: AVError
    public init(fmt: AVOutputFormat?, formatName: String?, filename: String?) throws {
        var ctxPtr: UnsafeMutablePointer<CAVFormatContext>?
        try throwIfFail(avformat_alloc_output_context2(&ctxPtr, fmt?.fmtPtr, formatName, filename))
        self.ctxPtr = ctxPtr!
    }

    /// Input or output URL.
    public var url: String? {
        if let strBytes = ctxPtr.pointee.url {
            return String(cString: strBytes)
        }
        return nil
    }

    /// The input container format.
    public var iformat: AVInputFormat? {
        get {
            if let fmtPtr = ctx.iformat {
                return AVInputFormat(fmtPtr: fmtPtr)
            }
            return nil
        }
        set {
            ctxPtr.pointee.iformat = newValue?.fmtPtr
        }
    }

    /// The output container format.
    public var oformat: AVOutputFormat? {
        get {
            if let fmtPtr = ctx.oformat {
                return AVOutputFormat(fmtPtr: fmtPtr)
            }
            return nil
        }
        set {
            ctxPtr.pointee.oformat = newValue?.fmtPtr
        }
    }

    /// Number of streams.
    public var streamCount: Int {
        return Int(ctx.nb_streams)
    }

    /// A list of all streams in the file.
    public var streams: [AVStream] {
        var list = [AVStream]()
        for i in 0..<streamCount {
            let stream = ctx.streams.advanced(by: i).pointee!
            list.append(AVStream(streamPtr: stream))
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

    /// Duration of the stream, in `AV_TIME_BASE` fractional seconds.
    public var duration: Int64 {
        return ctxPtr.pointee.duration
    }

    /// Metadata that applies to the whole file.
    public var metadata: [String: String] {
        var dict = [String: String]()
        var tag: UnsafeMutablePointer<AVDictionaryEntry>?
        while let next = av_dict_get(ctx.metadata, "", tag, AV_DICT_IGNORE_SUFFIX) {
            dict[String(cString: next.pointee.key)] = String(cString: next.pointee.value)
            tag = next
        }
        return dict
    }

    /// Open an input stream and read the header.
    ///
    /// - Parameter url: URL of the stream to open.
    public func openInput(_ url: String) throws {
        var ps: UnsafeMutablePointer<CAVFormatContext>? = ctxPtr
        try throwIfFail(avformat_open_input(&ps, url, nil, nil))
        isOpened = true
    }

    /// Read packets of a media file to get stream information.
    public func findStreamInfo() throws {
        try throwIfFail(avformat_find_stream_info(ctxPtr, nil))
    }

    /// Find the "best" stream in the file.
    ///
    /// - Parameter type: stream type: video, audio, subtitles, etc.
    /// - Returns: stream number
    /// - Throws: AVError
    public func findBestStream(type: AVMediaType) throws -> Int {
        let ret = av_find_best_stream(ctxPtr, type, -1, -1, nil, 0)
        try throwIfFail(ret)
        return Int(ret)
    }

    public func streamIndex(for mediaType: AVMediaType) -> Int? {
        if let index = streams.index(where: { $0.codecpar.mediaType == mediaType }) {
            return index
        }
        return nil
    }

    /// Add a new stream to a media file.
    ///
    /// - Parameter codec: If non-nil, the AVCodecContext corresponding to the new stream will be initialized to use this codec.
    ///   This is needed for e.g. codec-specific defaults to be set, so codec should be provided if it is known.
    /// - Returns: newly created stream or `nil` on error.
    public func addStream(codec: AVCodec?) -> AVStream? {
        if let streamPtr = avformat_new_stream(ctxPtr, codec?.codecPtr) {
            return AVStream(streamPtr: streamPtr)
        }
        return nil
    }

    /// Return the next frame of a stream.
    ///
    /// This function returns what is stored in the file, and does not validate that what is there are valid frames
    /// for the decoder. It will split what is stored in the file into frames and return one for each call. It will
    /// not omit invalid data between valid frames so as to give the decoder the maximum information possible for decoding.
    ///
    /// - Parameter packet: packet
    /// - Throws: AVError
    public func readFrame(into packet: AVPacket) throws {
        try throwIfFail(av_read_frame(ctxPtr, packet.packetPtr))
    }

    /// Create and initialize a AVIOContext for accessing the resource indicated by url.
    ///
    /// - Parameters:
    ///   - url: resource to access
    ///   - mode: flags which control how the resource indicated by url is to be opened
    /// - Throws: AVError
    public func openIO(url: String, mode: Int32) throws {
        var pb: UnsafeMutablePointer<AVIOContext>?
        try throwIfFail(avio_open(&pb, url, mode))
        ctxPtr.pointee.pb = pb
    }

    /// Allocate the stream private data and write the stream header to an output media file.
    ///
    /// - Parameter options: An AVDictionary filled with AVFormatContext and muxer-private options.
    /// - Throws: AVError
    public func writeHeader(options: [String: String]? = nil) throws {
        var pm: OpaquePointer?
        defer { av_dict_free(&pm) }
        if let options = options {
            for (k, v) in options {
                av_dict_set(&pm, k, v, 0)
            }
        }

        try throwIfFail(avformat_write_header(ctxPtr, &pm))

        dumpUnrecognizedOptions(pm)
    }

    /// Write the stream trailer to an output media file and free the file private data.
    ///
    /// May only be called after a successful call to `writeHeader(options:)`.
    ///
    /// - Throws: AVError
    public func writeTrailer() throws {
        try throwIfFail(av_write_trailer(ctxPtr))
    }

    /// Write a packet to an output media file.
    ///
    /// - Parameter pkt: The packet containing the data to be written.
    /// - Throws: AVError
    public func writeFrame(pkt: AVPacket?) throws {
        try throwIfFail(av_write_frame(ctxPtr, pkt?.packetPtr))
    }

    /// Write a packet to an output media file ensuring correct interleaving.
    ///
    /// - Parameter pkt: The packet containing the data to be written.
    /// - Throws: AVError
    public func interleavedWriteFrame(pkt: AVPacket?) throws {
        try throwIfFail(av_interleaved_write_frame(ctxPtr, pkt?.packetPtr))
    }

    /// Print detailed information about the input or output format, such as duration, bitrate, streams, container,
    /// programs, metadata, side data, codec and time base.
    ///
    /// - Parameters isOutput: Select whether the specified context is an input(0) or output(1).
    public func dumpFormat(isOutput: Bool) {
        av_dump_format(ctxPtr, 0, url, isOutput ? 1 : 0)
    }

    deinit {
        if let oformat = oformat, oformat.flags & AVFmtFlag.noFile == 0 {
            var pb = ctx.pb
            avio_closep(&pb)
        }

        if isOpened {
            var ps: UnsafeMutablePointer<CAVFormatContext>? = ctxPtr
            avformat_close_input(&ps)
        } else {
            avformat_free_context(ctxPtr)
        }
    }
}
