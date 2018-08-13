//
//  AVFrame.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVFrame

internal typealias CAVFrame = CFFmpeg.AVFrame

/// This structure describes decoded (raw) audio or video data.
///
/// AVFrame must be allocated using av_frame_alloc(). Note that this only
/// allocates the AVFrame itself, the buffers for the data must be managed
/// through other means (see below).
/// AVFrame must be freed with av_frame_free().
///
/// AVFrame is typically allocated once and then reused multiple times to hold
/// different data (e.g. a single AVFrame to hold frames received from a
/// decoder). In such a case, av_frame_unref() will free any references held by
/// the frame and reset it to its original clean state before it
/// is reused again.
///
/// The data described by an AVFrame is usually reference counted through the
/// AVBuffer API. The underlying buffer references are stored in AVFrame.buf /
/// AVFrame.extended_buf. An AVFrame is considered to be reference counted if at
/// least one reference is set, i.e. if AVFrame.buf[0] != NULL. In such a case,
/// every single data plane must be contained in one of the buffers in
/// AVFrame.buf or AVFrame.extended_buf.
/// There may be a single buffer for all the data, or one separate buffer for
/// each plane, or anything in between.
///
/// sizeof(AVFrame) is not a part of the public ABI, so new fields may be added
/// to the end with a minor bump.
///
/// Fields can be accessed through AVOptions, the name string used, matches the
/// C structure field name for fields accessible through AVOptions. The AVClass
/// for AVFrame can be obtained from avcodec_get_frame_class()
public final class AVFrame {
    internal let framePtr: UnsafeMutablePointer<CAVFrame>
    internal var frame: CAVFrame { return framePtr.pointee }

    public var mediaType: AVMediaType = .unknown

    internal init(framePtr: UnsafeMutablePointer<CAVFrame>) {
        self.framePtr = framePtr
    }

    /// Creates an `AVFrame` and set its fields to default values.
    public init() {
        guard let framePtr = av_frame_alloc() else {
            fatalError("av_frame_alloc")
        }
        self.framePtr = framePtr
    }

    /// `AVBuffer` references backing the data for this frame.
    ///
    /// If all elements of this array are `nil`, then this frame is not reference counted.
    /// This array must be filled contiguously -- if `buf[i]` is non-nil then `buf[j]` must also be non-nil for all
    /// `j < i`.
    ///
    /// There may be at most one `AVBuffer` per data plane, so for video this array always contains all the references.
    /// For planar audio with more than `AV_NUM_DATA_POINTERS` channels, there may be more buffers than can fit in this
    /// array. Then the extra `AVBufferRef` pointers are stored in the `extended_buf` array.
    public var buf: [AVBuffer?] {
        get {
            let list = [
                frame.buf.0, frame.buf.1, frame.buf.2, frame.buf.3,
                frame.buf.4, frame.buf.5, frame.buf.6, frame.buf.7
            ]
            return list.map({ AVBuffer(bufPtr: $0) })
        }
        set {
            var list = newValue
            while list.count < AV_NUM_DATA_POINTERS {
                list.append(nil)
            }
            var ptrs = list.map({ $0?.bufPtr })
            framePtr.pointee.buf = (
                ptrs[0], ptrs[1], ptrs[2], ptrs[3],
                ptrs[4], ptrs[5], ptrs[6], ptrs[7]
            )
        }
    }

    /// Pointer to the picture/channel planes.
    public var data: [UnsafeMutablePointer<UInt8>?] {
        get {
            return [
                frame.data.0, frame.data.1, frame.data.2, frame.data.3,
                frame.data.4, frame.data.5, frame.data.6, frame.data.7
            ]
        }
        set {
            var list = newValue
            while list.count < AV_NUM_DATA_POINTERS {
                list.append(nil)
            }
            framePtr.pointee.data = (
                list[0], list[1], list[2], list[3],
                list[4], list[5], list[6], list[7]
            )
        }
    }

    /// For video, size in bytes of each picture line.
    ///
    /// For audio, size in bytes of each plane.
    public var linesize: [Int] {
        get {
            let list = [
                frame.linesize.0, frame.linesize.1, frame.linesize.2, frame.linesize.3,
                frame.linesize.4, frame.linesize.5, frame.linesize.6, frame.linesize.7
            ]
            return list.map({ Int($0) })
        }
        set {
            var list = newValue.map({ Int32($0) })
            while list.count < AV_NUM_DATA_POINTERS {
                list.append(0)
            }
            framePtr.pointee.linesize = (
                list[0], list[1], list[2], list[3],
                list[4], list[5], list[6], list[7]
            )
        }
    }

    /// Presentation timestamp in timebase units (time when frame should be shown to user).
    public var pts: Int64 {
        get { return frame.pts }
        set { framePtr.pointee.pts = newValue }
    }

    /// DTS copied from the AVPacket that triggered returning this frame. (if frame threading isn't used)
    /// This is also the Presentation time of this AVFrame calculated from only AVPacket.dts values without pts values.
    public var dts: Int64 {
        return frame.pkt_dts
    }

    /// Picture number in bitstream order.
    public var codedPictureNumber: Int {
        return Int(frame.coded_picture_number)
    }

    /// Picture number in display order.
    public var displayPictureNumber: Int {
        return Int(frame.display_picture_number)
    }

    /// Metadata.
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by libavcodec.
    public var metadata: [String: String] {
        var dict = [String: String]()
        var tag: UnsafeMutablePointer<AVDictionaryEntry>?
        while let next = av_dict_get(frame.metadata, "", tag, AV_DICT_IGNORE_SUFFIX) {
            dict[String(cString: next.pointee.key)] = String(cString: next.pointee.value)
            tag = next
        }
        return dict
    }

    /// Size of the corresponding packet containing the compressed frame. It is set to a negative value if unknown.
    ///
    /// - encoding: Unused.
    /// - decoding: Set by libavcodec, read by user.
    public var pktSize: Int {
        return Int(frame.pkt_size)
    }

    /// Set up a new reference to the data described by the source frame.
    ///
    /// Copy frame properties from src to dst and create a new reference for each
    /// AVBufferRef from src.
    ///
    /// If src is not reference counted, new buffers are allocated and the data is
    /// copied.
    ///
    /// - Warning: dst MUST have been either unreferenced with av_frame_unref(dst),
    ///           or newly allocated with av_frame_alloc() before calling this
    ///           function, or undefined behavior will occur.
    /// - Throws: AVError
    public func ref() throws -> AVFrame {
        let frame = AVFrame()
        try throwIfFail(av_frame_ref(frame.framePtr, framePtr))
        return frame
    }

    /// Unreference all the buffers referenced by frame and reset the frame fields.
    public func unref() {
        av_frame_unref(framePtr)
    }

    /// Create a new frame that references the same data as src.
    ///
    /// This is a shortcut for `av_frame_alloc() + av_frame_ref()`.
    ///
    /// - Returns: newly created AVFrame on success, NULL on error.
    public func clone() -> AVFrame? {
        if let ptr = av_frame_clone(framePtr) {
            return AVFrame(framePtr: ptr)
        }
        return nil
    }

    /// Allocate new buffer(s) for audio or video data.
    ///
    /// The following fields must be set on frame before calling this function:
    ///   - format (pixel format for video, sample format for audio)
    ///   - width and height for video
    ///   - sampleCount and channelLayout for audio
    ///
    /// This function will fill `AVFrame.data` and `AVFrame.buf` arrays and, if necessary, allocate and fill
    /// `AVFrame.extended_data` and `AVFrame.extended_buf`. For planar formats, one buffer will be allocated for
    ///  each plane.
    ///
    /// - Warning: If frame already has been allocated, calling this function will leak memory.
    ///   In addition, undefined behavior can occur in certain cases.
    ///
    /// - Parameter align: Required buffer size alignment. If equal to 0, alignment will be chosen automatically
    ///   for the current CPU. It is highly recommended to pass 0 here unless you know what you are doing.
    /// - Throws: AVError
    public func allocBuffer(align: Int = 0) throws {
        try throwIfFail(av_frame_get_buffer(framePtr, Int32(align)))
    }

    /// Check if the frame data is writable.
    ///
    /// - Returns: True if the frame data is writable (which is true if and only if each of the underlying buffers has
    ///   only one reference, namely the one stored in this frame).
    public func isWritable() -> Bool {
        return av_frame_is_writable(framePtr) > 0
    }

    /// Ensure that the frame data is writable, avoiding data copy if possible.
    ///
    /// Do nothing if the frame is writable, allocate new buffers and copy the data if it is not.
    ///
    /// - Throws: AVError
    public func makeWritable() throws {
        try throwIfFail(av_frame_make_writable(framePtr))
    }

    deinit {
        var ptr: UnsafeMutablePointer<CAVFrame>? = framePtr
        av_frame_free(&ptr)
    }
}

// MARK: - Video

extension AVFrame {

    /// Pixel format.
    public var pixFmt: AVPixelFormat {
        get { return AVPixelFormat(frame.format) }
        set { framePtr.pointee.format = newValue.rawValue }
    }

    /// picture width
    public var width: Int {
        get { return Int(frame.width) }
        set { framePtr.pointee.width = Int32(newValue) }
    }

    /// picture height
    public var height: Int {
        get { return Int(frame.height) }
        set { framePtr.pointee.height = Int32(newValue) }
    }

    /// Returns whether this frame is key frame.
    public var isKeyFrame: Bool {
        return frame.key_frame == 1
    }

    /// Picture type of the frame.
    public var pictType: AVPictureType {
        return frame.pict_type
    }

    /// Sample aspect ratio for the video frame, 0/1 if unknown/unspecified.
    public var sampleAspectRatio: AVRational {
        get { return frame.sample_aspect_ratio }
        set { framePtr.pointee.sample_aspect_ratio = newValue }
    }
}

// MARK: - Audio

extension AVFrame {

    /// Sample format.
    public var sampleFmt: AVSampleFormat {
        get { return AVSampleFormat(frame.format) }
        set { framePtr.pointee.format = newValue.rawValue }
    }

    /// Sample rate of the audio data.
    public var sampleRate: Int {
        get { return Int(frame.sample_rate) }
        set { framePtr.pointee.sample_rate = Int32(newValue) }
    }

    /// Channel layout of the audio data.
    public var channelLayout: AVChannelLayout {
        get { return AVChannelLayout(rawValue: frame.channel_layout) }
        set { framePtr.pointee.channel_layout = newValue.rawValue }
    }

    /// Number of audio samples (per channel) described by this frame.
    public var sampleCount: Int {
        get { return Int(frame.nb_samples) }
        set { framePtr.pointee.nb_samples = Int32(newValue) }
    }

    /// Number of audio channels.
    ///
    /// - encoding: Unused.
    /// - decoding: Read by user.
    public var channelCount: Int {
        get { return Int(frame.channels) }
        set { framePtr.pointee.channels = Int32(newValue) }
    }
}
