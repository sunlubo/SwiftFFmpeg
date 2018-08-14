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
/// `AVFrame` is typically allocated once and then reused multiple times to hold
/// different data (e.g. a single `AVFrame` to hold frames received from a decoder).
/// In such a case, `unref` will free any references held by the frame and reset it
/// to its original clean state before it is reused again.
///
/// The data described by an `AVFrame` is usually reference counted through the
/// `AVBuffer` API. The underlying buffer references are stored in `AVFrame.buf` /
/// `AVFrame.extended_buf`. An `AVFrame` is considered to be reference counted if at
/// least one reference is set, i.e. if `AVFrame.buf[0] != nil`. In such a case,
/// every single data plane must be contained in one of the buffers in `AVFrame.buf`
/// or `AVFrame.extended_buf`.
/// There may be a single buffer for all the data, or one separate buffer for
/// each plane, or anything in between.
///
/// Fields can be accessed through `AVOptions`, the name string used, matches the
/// C structure field name for fields accessible through `AVOptions`.
public final class AVFrame {
    internal let framePtr: UnsafeMutablePointer<CAVFrame>
    internal var frame: CAVFrame { return framePtr.pointee }

    public var mediaType: AVMediaType = .unknown

    internal init(framePtr: UnsafeMutablePointer<CAVFrame>) {
        self.framePtr = framePtr
    }

    /// Creates an `AVFrame` and set its fields to default values.
    ///
    /// - Note: This only allocates the `AVFrame` itself, not the data buffers.
    ///   Those must be allocated through other means, e.g. with `allocBuffer` or manually.
    public init() {
        guard let framePtr = av_frame_alloc() else {
            fatalError("av_frame_alloc")
        }
        self.framePtr = framePtr
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
    /// For audio, size in bytes of each plane.
    ///
    /// For audio, only linesize[0] may be set.
    /// For planar audio, each channel plane must be the same size.
    ///
    /// For video the linesizes should be multiples of the CPUs alignment preference, this is 16 or 32
    /// for modern desktop CPUs. Some code requires such alignment other code can be slower without correct
    /// alignment, for yet other it makes no difference.
    ///
    /// - Note: The linesize may be larger than the size of usable data -- there may be extra padding present
    ///   for performance reasons.
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
    /// This is also the Presentation time of this `AVFrame` calculated from only `AVPacket.dts` values
    /// without pts values.
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

    /// `AVBuffer` references backing the data for this frame.
    ///
    /// If all elements of this array are `nil`, then this frame is not reference counted.
    /// This array must be filled contiguously -- if `buf[i]` is non-nil then `buf[j]` must
    /// also be non-nil for all `j < i`.
    ///
    /// There may be at most one `AVBuffer` per data plane, so for video this array always
    /// contains all the references. For planar audio with more than `AV_NUM_DATA_POINTERS`
    /// channels, there may be more buffers than can fit in this array. Then the extra
    /// `AVBuffer` are stored in the `extendedBuf` array.
    public var buf: [AVBuffer?] {
        let list = [
            frame.buf.0, frame.buf.1, frame.buf.2, frame.buf.3,
            frame.buf.4, frame.buf.5, frame.buf.6, frame.buf.7
        ]
        return list.map({ $0 != nil ? AVBuffer(bufPtr: $0!) : nil })
    }

    /// For planar audio which requires more than `AV_NUM_DATA_POINTERS` `AVBuffer`,
    /// this array will hold all the references which cannot fit into `AVFrame.buf`.
    ///
    /// Note that this is different from `AVFrame.extended_data`, which always contains all the pointers.
    /// This array only contains the extra pointers, which cannot fit into `AVFrame.buf`.
    public var extendedBuf: [AVBuffer] {
        var list = [AVBuffer]()
        for i in 0..<extendedBufCount {
            list.append(AVBuffer(bufPtr: frame.extended_buf[i]!))
        }
        return list
    }

    /// The number of elements in `extendedBuf`.
    public var extendedBufCount: Int {
        return Int(frame.nb_extended_buf)
    }

    /// Reordered pos from the last `AVPacket` that has been input into the decoder.
    ///
    /// - encoding: Unused.
    /// - decoding: Set by libavcodec, read by user.
    public var pktPos: Int64 {
        return frame.pkt_pos
    }

    /// Duration of the corresponding packet, expressed in `AVStream.timebase` units, 0 if unknown.
    ///
    /// - encoding: Unused.
    /// - decoding: Set by libavcodec, read by user.
    public var pktDuration: Int64 {
        return frame.pkt_duration
    }

    /// Size of the corresponding packet containing the compressed frame. It is set to a negative value if unknown.
    ///
    /// - encoding: Unused.
    /// - decoding: Set by libavcodec, read by user.
    public var pktSize: Int {
        return Int(frame.pkt_size)
    }

    /// The metadata of the frame.
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by libavcodec.
    public var metadata: [String: String] {
        get {
            var dict = [String: String]()
            var tag: UnsafeMutablePointer<AVDictionaryEntry>?
            while let next = av_dict_get(frame.metadata, "", tag, AV_DICT_IGNORE_SUFFIX) {
                dict[String(cString: next.pointee.key)] = String(cString: next.pointee.value)
                tag = next
            }
            return dict
        }
        set {
            var ptr = framePtr.pointee.metadata
            for (k, v) in newValue {
                av_dict_set(&ptr, k, v, AVOptionSearchFlag.children.rawValue)
            }
            framePtr.pointee.metadata = ptr
        }
    }

    /// Set up a new reference to the data described by the source frame.
    ///
    /// Copy frame properties from src to dst and create a new reference for each `AVBuffer` from src.
    /// If src is not reference counted, new buffers are allocated and the data is copied.
    ///
    /// - Warning: dst MUST have been either unreferenced with av_frame_unref(dst),
    ///           or newly allocated with av_frame_alloc() before calling this
    ///           function, or undefined behavior will occur.
    /// - Throws: AVError
    public func ref(dst: AVFrame) throws {
        try throwIfFail(av_frame_ref(dst.framePtr, framePtr))
    }

    /// Unreference all the buffers referenced by frame and reset the frame fields.
    public func unref() {
        av_frame_unref(framePtr)
    }

    /// Create a new frame that references the same data as src.
    ///
    /// This is a shortcut for `av_frame_alloc() + av_frame_ref()`.
    ///
    /// - Returns: newly created `AVFrame` on success, nil on error.
    public func clone() -> AVFrame? {
        if let ptr = av_frame_clone(framePtr) {
            return AVFrame(framePtr: ptr)
        }
        return nil
    }

    /// Allocate new buffer(s) for audio or video data.
    ///
    /// The following fields must be set on frame before calling this function:
    ///   - `pixFmt` for video, `sampleFmt` for audio
    ///   - `width` and `height` for video
    ///   - `sampleCount` and `channelLayout` for audio
    ///
    /// This function will fill `AVFrame.data` and `AVFrame.buf` arrays and, if necessary, allocate and fill
    /// `AVFrame.extendedData` and `AVFrame.extendedBuf`. For planar formats, one buffer will be allocated for
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

    /// Picture width.
    public var width: Int {
        get { return Int(frame.width) }
        set { framePtr.pointee.width = Int32(newValue) }
    }

    /// Picture height.
    public var height: Int {
        get { return Int(frame.height) }
        set { framePtr.pointee.height = Int32(newValue) }
    }

    /// A Boolean value indicating whether this frame is key frame.
    public var isKeyFrame: Bool {
        return frame.key_frame == 1
    }

    /// The picture type of the frame.
    public var pictType: AVPictureType {
        return frame.pict_type
    }

    /// The sample aspect ratio for the video frame, 0/1 if unknown/unspecified.
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

    /// The sample rate of the audio data.
    public var sampleRate: Int {
        get { return Int(frame.sample_rate) }
        set { framePtr.pointee.sample_rate = Int32(newValue) }
    }

    /// The channel layout of the audio data.
    public var channelLayout: AVChannelLayout {
        get { return AVChannelLayout(rawValue: frame.channel_layout) }
        set { framePtr.pointee.channel_layout = newValue.rawValue }
    }

    /// The number of audio samples (per channel) described by this frame.
    public var sampleCount: Int {
        get { return Int(frame.nb_samples) }
        set { framePtr.pointee.nb_samples = Int32(newValue) }
    }

    /// The number of audio channels.
    ///
    /// - encoding: Unused.
    /// - decoding: Read by user.
    public var channelCount: Int {
        get { return Int(frame.channels) }
        set { framePtr.pointee.channels = Int32(newValue) }
    }
}
