//
//  AVFormat.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/16.
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

    /// `AVClass` for the private context.
    public var privClass: AVClass? {
        if let classPtr = cFormat.priv_class {
            return AVClass(cClassPtr: classPtr)
        }
        return nil
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

// MARK: - AVInputFormat.Flag

extension AVInputFormat {

    /// Flags used by `flags`.
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

    /// The default audio codec of the muxer.
    public var audioCodec: AVCodecID {
        return cFormat.audio_codec
    }

    /// The default video codec of the muxer.
    public var videoCodec: AVCodecID {
        return cFormat.video_codec
    }

    /// The default subtitle codec of the muxer.
    public var subtitleCodec: AVCodecID {
        return cFormat.subtitle_codec
    }

    public var flags: Flag {
        get { return Flag(rawValue: cFormat.flags) }
        set { cFormatPtr.pointee.flags = newValue.rawValue }
    }

    /// `AVClass` for the private context.
    public var privClass: AVClass? {
        if let classPtr = cFormat.priv_class {
            return AVClass(cClassPtr: classPtr)
        }
        return nil
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

// MARK: - AVOutputFormat.Flag

extension AVOutputFormat {

    /// Flags used by `flags`.
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
