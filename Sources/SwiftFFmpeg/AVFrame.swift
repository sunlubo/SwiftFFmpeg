//
//  AVFrame.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVFrame

typealias CAVFrame = CFFmpeg.AVFrame

/// This structure describes decoded (raw) audio or video data.
///
/// `AVFrame` is typically allocated once and then reused multiple times to hold
/// different data (e.g. a single `AVFrame` to hold frames received from a decoder).
/// In such a case, `unref()` will free any references held by the frame and reset it
/// to its original clean state before it is reused again.
///
/// The data described by an `AVFrame` is usually reference counted through the
/// `AVBuffer` API. The underlying buffer references are stored in `buffer` /
/// `extendedBuffer`. An `AVFrame` is considered to be reference counted if at
/// least one reference is set, i.e. if `buffer[0] != nil`. In such a case,
/// every single data plane must be contained in one of the buffers in `buffer`
/// or `extendedBuffer`.
/// There may be a single buffer for all the data, or one separate buffer for
/// each plane, or anything in between.
public final class AVFrame {
  var native: UnsafeMutablePointer<CAVFrame>!

  init(native: UnsafeMutablePointer<CAVFrame>) {
    self.native = native
  }

  /// Creates an `AVFrame` and set its fields to default values.
  ///
  /// - Note: This only allocates the `AVFrame` itself, not the data buffers.
  ///   Those must be allocated through other means, e.g. with `allocBuffer(align:)` or manually.
  public init() {
    self.native = av_frame_alloc()
  }

  deinit {
    av_frame_free(&native)
  }

  /// Pointer to the picture/channel planes.
  public var data: UnsafeMutableBufferPointer<UnsafeMutablePointer<UInt8>?> {
    get {
      return withUnsafeMutableBytes(of: &native.pointee.data) { ptr in
        return ptr.bindMemory(to: UnsafeMutablePointer<UInt8>?.self)
      }
    }
    set {
      withUnsafeMutableBytes(of: &native.pointee.data) { ptr in
        ptr.copyMemory(from: UnsafeRawBufferPointer(newValue))
      }
    }
  }

  /// For video, size in bytes of each picture line.
  /// For audio, size in bytes of each plane.
  ///
  /// For audio, only `linesize[0]` may be set.
  /// For planar audio, each channel plane must be the same size.
  ///
  /// For video the linesizes should be multiples of the CPUs alignment preference, this is 16 or 32
  /// for modern desktop CPUs. Some code requires such alignment other code can be slower without correct
  /// alignment, for yet other it makes no difference.
  ///
  /// - Note: The linesize may be larger than the size of usable data -- there may be extra padding present
  ///   for performance reasons.
  public var linesize: UnsafeMutableBufferPointer<Int32> {
    get {
      return withUnsafeMutableBytes(of: &native.pointee.linesize) { ptr in
        return ptr.bindMemory(to: Int32.self)
      }
    }
    set {
      withUnsafeMutableBytes(of: &native.pointee.linesize) { ptr in
        ptr.copyMemory(from: UnsafeRawBufferPointer(newValue))
      }
    }
  }

  /// pointers to the data planes/channels.
  ///
  /// For video, this should simply point to `data`.
  ///
  /// For planar audio, each channel has a separate data pointer, and `linesize[0]` contains
  /// the size of each channel buffer.
  /// For packed audio, there is just one data pointer, and `linesize[0]` contains
  /// the total size of the buffer for all channels.
  ///
  /// - Note: Both `data` and `extendedData` should always be set in a valid frame,
  ///   but for planar audio with more channels that can fit in `data`,
  ///   `extendedData` must be used in order to access all channels.
  public var extendedData: UnsafeMutableBufferPointer<UnsafeMutablePointer<UInt8>?> {
    get {
      let count = pixelFormat != .none ? 4 : channelLayout.channelCount
      return UnsafeMutableBufferPointer(start: native.pointee.extended_data, count: count)
    }
    set { native.pointee.extended_data = newValue.baseAddress }
  }

  /// Presentation timestamp in timebase units (time when frame should be shown to user).
  public var pts: Int64 {
    get { native.pointee.pts }
    set { native.pointee.pts = newValue }
  }

  /// DTS copied from the `AVPacket` that triggered returning this frame. (if frame threading isn't used)
  /// This is also the presentation time of this `AVFrame` calculated from only `AVPacket.dts` values
  /// without pts values.
  public var dts: Int64 {
    native.pointee.pkt_dts
  }

  /// `AVBuffer` references backing the data for this frame.
  ///
  /// If all elements of this array are `nil`, then this frame is not reference counted.
  /// This array must be filled contiguously -- if `buffer[i]` is non-nil then `buffer[j]` must
  /// also be non-nil for all `j < i`.
  ///
  /// There may be at most one `AVBuffer` per data plane, so for video this array always
  /// contains all the references. For planar audio with more than `AVConstant.dataPointersNumber`
  /// channels, there may be more buffers than can fit in this array. Then the extra
  /// `AVBuffer` are stored in the `extendedBuffer` array.
  public var buffer: [AVBuffer?] {
    let list = [
      native.pointee.buf.0, native.pointee.buf.1, native.pointee.buf.2, native.pointee.buf.3,
      native.pointee.buf.4, native.pointee.buf.5, native.pointee.buf.6, native.pointee.buf.7,
    ]
    return list.map({ $0 != nil ? AVBuffer(native: $0!) : nil })
  }

  /// For planar audio which requires more than `AVConstant.dataPointersNumber` `AVBuffer`,
  /// this array will hold all the references which cannot fit into `buffer`.
  ///
  /// Note that this is different from `extendedData`, which always contains all the pointers.
  /// This array only contains the extra pointers, which cannot fit into `buffer`.
  public var extendedBuffer: [AVBuffer] {
    var list = [AVBuffer]()
    for i in 0 ..< extendedBufferCount {
      list.append(AVBuffer(native: native.pointee.extended_buf[i]!))
    }
    return list
  }

  /// The number of elements in `extendedBuffer`.
  public var extendedBufferCount: Int {
    Int(native.pointee.nb_extended_buf)
  }

  public var sideData: [AVFrameSideData] {
    var list = [AVFrameSideData]()
    for i in 0 ..< sideDataCount {
      list.append(AVFrameSideData(native: native.pointee.side_data[i]!))
    }
    return list
  }

  /// The number of elements in `sideData`.
  public var sideDataCount: Int {
    Int(native.pointee.nb_side_data)
  }

  /// The frame timestamp estimated using various heuristics, in stream timebase.
  ///
  /// - encoding: Unused.
  /// - decoding: Set by libavcodec, read by user.
  public var bestEffortTimestamp: Int64 {
    native.pointee.best_effort_timestamp
  }

  /// Duration of the frame, in the same units as pts. 0 if unknown.
  public var duration: Int64 {
    native.pointee.duration
  }

  /// The metadata of the frame.
  ///
  /// - encoding: Set by user.
  /// - decoding: Set by libavcodec.
  public var metadata: [String: String] {
    get {
      var dict = [String: String]()
      var tag: UnsafeMutablePointer<AVDictionaryEntry>?
      while let next = av_dict_get(native.pointee.metadata, "", tag, AV_DICT_IGNORE_SUFFIX) {
        dict[String(cString: next.pointee.key)] = String(cString: next.pointee.value)
        tag = next
      }
      return dict
    }
    set {
      var ptr = native.pointee.metadata
      for (k, v) in newValue {
        av_dict_set(&ptr, k, v, AV_OPT_SEARCH_CHILDREN)
      }
      native.pointee.metadata = ptr
    }
  }

  /// A Boolean value indicating whether the frame data is writable.
  ///
  /// `true` if the frame data is writable (which is `true` if and only if each of the
  /// underlying buffers has only one reference, namely the one stored in this frame).
  public var isWritable: Bool {
    av_frame_is_writable(native) > 0
  }

  /// Allocate new buffer(s) for audio or video data.
  ///
  /// The following fields must be set on frame before calling this function:
  ///   - `pixelFormat` for video, `sampleFormat` for audio
  ///   - `width` and `height` for video
  ///   - `sampleCount` and `channelLayout` for audio
  ///
  /// This function will fill `data` and `buffer` arrays and, if necessary,
  /// allocate and fill `extendedData` and `extendedBuffer`. For planar formats,
  /// one buffer will be allocated for each plane.
  ///
  /// - Warning: If frame already has been allocated, calling this function will leak memory.
  ///   In addition, undefined behavior can occur in certain cases.
  ///
  /// - Parameter align: Required buffer size alignment.
  ///   If equal to 0, alignment will be chosen automatically for the current CPU.
  ///   It is highly recommended to pass 0 here unless you know what you are doing.
  /// - Throws: AVError
  public func allocBuffer(align: Int = 0) throws {
    try throwIfFail(av_frame_get_buffer(native, Int32(align)))
  }

  /// Set up a new reference to the data described by the source frame.
  ///
  /// Copy frame properties from `src` to this frame and create a new reference for each
  /// `AVBuffer` from `src`. If `src` is not reference counted, new buffers are allocated
  /// and the data is copied.
  ///
  /// - Warning: this frame __must__ have been either unreferenced with `unref()`, or newly
  ///   created before calling this function, or undefined behavior will occur.
  ///
  /// - Parameter src: the source frame
  /// - Throws: AVError
  public func ref(from src: AVFrame) throws {
    try throwIfFail(av_frame_ref(native, src.native))
  }

  /// Unreference all the buffers referenced by frame and reset the frame fields.
  public func unref() {
    av_frame_unref(native)
  }

  /// Move everything contained in `src` to this frame and reset `src`.
  ///
  /// - Warning: This frame is not unreferenced, but directly overwritten without reading
  ///   or deallocating its contents. Call `unref()` on this frame manually before calling
  ///   this function to ensure that no memory is leaked.
  ///
  /// - Parameter src: the source frame
  public func moveRef(from src: AVFrame) {
    av_frame_move_ref(native, src.native)
  }

  /// Create a new frame that references the same data as this frame.
  ///
  /// This is a shortcut for `init() + ref(from:)`.
  ///
  /// - Returns: newly created `AVFrame` on success, `nil` on error.
  public func clone() -> AVFrame? {
    av_frame_clone(native).map(AVFrame.init(native:))
  }

  /// Ensure that the frame data is writable, avoiding data copy if possible.
  ///
  /// Do nothing if the frame is writable, allocate new buffers and copy the data if it is not.
  ///
  /// - Throws: AVError
  public func makeWritable() throws {
    try throwIfFail(av_frame_make_writable(native))
  }

  /// Copy the frame data from `src` to this frame.
  ///
  /// This function does not allocate anything, this frame must be already initialized
  /// and allocated with the same parameters as `src`.
  ///
  /// This function only copies the frame data (i.e. the contents of the `data` /
  /// `extendedData` arrays), not any other properties.
  ///
  /// - Parameter src: the source frame
  /// - Throws: AVError
  public func copy(from src: AVFrame) throws {
    try throwIfFail(av_frame_copy(native, src.native))
  }

  /// Copy only "metadata" fields from `src` to this frame.
  ///
  /// Metadata for the purpose of this function are those fields that do not affect
  /// the data layout in the buffers. E.g. pts, sample rate (for audio) or sample
  /// aspect ratio (for video), but not width/height or channel layout.
  /// Side data is also copied.
  ///
  /// - Parameter src: the source frame
  /// - Throws: AVError
  public func copyProperties(from src: AVFrame) throws {
    try throwIfFail(av_frame_copy_props(native, src.native))
  }

  /// Get the buffer reference a given data plane is stored in.
  ///
  /// - Parameter plane: index of the data plane of interest in `extendedData`.
  /// - Returns: the buffer reference that contains the plane or `nil` if the input frame is not valid.
  public func planeBuffer(at plane: Int) -> AVBuffer? {
    av_frame_get_plane_buffer(native, Int32(plane)).map(AVBuffer.init(native:))
  }
}

// MARK: - Video

extension AVFrame {
  /// The pixel format of the picture.
  public var pixelFormat: AVPixelFormat {
    get { AVPixelFormat(native.pointee.format) }
    set { native.pointee.format = newValue.rawValue }
  }

  /// The width of the picture, in pixels.
  public var width: Int {
    get { Int(native.pointee.width) }
    set { native.pointee.width = Int32(newValue) }
  }

  /// The height of the picture, in pixels.
  public var height: Int {
    get { Int(native.pointee.height) }
    set { native.pointee.height = Int32(newValue) }
  }

  /// Frame flags,
  public var flags: Flag {
    get { Flag(rawValue: native.pointee.flags) }
    set { native.pointee.flags = newValue.rawValue }
  }

  /// The picture type of the frame.
  public var pictureType: AVPictureType {
    get { AVPictureType(native: native.pointee.pict_type) }
    set { native.pointee.pict_type = newValue.native }
  }

  /// The sample aspect ratio for the video frame, 0/1 if unknown/unspecified.
  public var sampleAspectRatio: AVRational {
    get { native.pointee.sample_aspect_ratio }
    set { native.pointee.sample_aspect_ratio = newValue }
  }

  /// When decoding, this signals how much the picture must be delayed.
  /// ```extra_delay = repeat_pict / (2*fps)```
  public var repeatPicture: Int {
    Int(native.pointee.repeat_pict)
  }

  /// The color range of the picture.
  public var colorRange: AVColorRange {
    get { AVColorRange(native: native.pointee.color_range) }
    set { native.pointee.color_range = newValue.native }
  }

  /// The color primaries of the picture.
  public var colorPrimaries: AVColorPrimaries {
    get { AVColorPrimaries(native: native.pointee.color_primaries) }
    set { native.pointee.color_primaries = newValue.native }
  }

  /// The color transfer characteristic of the picture.
  public var colorTransferCharacteristic: AVColorTransferCharacteristic {
    get { AVColorTransferCharacteristic(native: native.pointee.color_trc) }
    set { native.pointee.color_trc = newValue.native }
  }

  /// The color space of the picture.
  public var colorSpace: AVColorSpace {
    get { AVColorSpace(native: native.pointee.colorspace) }
    set { native.pointee.colorspace = newValue.native }
  }

  /// The chroma location of the picture.
  public var chromaLocation: AVChromaLocation {
    get { AVChromaLocation(native: native.pointee.chroma_location) }
    set { native.pointee.chroma_location = newValue.native }
  }
}

// MARK: - Audio

extension AVFrame {
  /// The sample format of the audio data.
  public var sampleFormat: AVSampleFormat {
    get { AVSampleFormat(rawValue: native.pointee.format)! }
    set { native.pointee.format = newValue.rawValue }
  }

  /// The sample rate of the audio data.
  public var sampleRate: Int {
    get { Int(native.pointee.sample_rate) }
    set { native.pointee.sample_rate = Int32(newValue) }
  }

  /// The channel layout of the audio data.
  public var channelLayout: AVChannelLayout {
    get { native.pointee.ch_layout }
    set { native.pointee.ch_layout = newValue }
  }

  /// The number of audio samples (per channel) described by this frame.
  public var sampleCount: Int {
    get { Int(native.pointee.nb_samples) }
    set { native.pointee.nb_samples = Int32(newValue) }
  }
}

// MARK: - AVFrame.Flag

extension AVFrame {
  public struct Flag: OptionSet {
    /// The frame data may be corrupted, e.g. due to decoding errors.
    public static let corrupt = Flag(rawValue: AV_FRAME_FLAG_CORRUPT)
    /// A flag to mark frames that are keyframes.
    public static let key = Flag(rawValue: AV_FRAME_FLAG_KEY)
    /// A flag to mark the frames which need to be decoded, but shouldn't be output.
    public static let discard = Flag(rawValue: AV_FRAME_FLAG_DISCARD)
    /// A flag to mark frames whose content is interlaced.
    public static let interlaced = Flag(rawValue: AV_FRAME_FLAG_INTERLACED)
    /// A flag to mark frames where the top field is displayed first if the content is interlaced.
    public static let topFieldFirst = Flag(rawValue: AV_FRAME_FLAG_TOP_FIELD_FIRST)

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
  }
}

extension AVFrame.Flag: CustomStringConvertible {
  public var description: String {
    var str = "["
    if contains(.corrupt) { str += "corrupt, " }
    if contains(.key) { str += "key, " }
    if contains(.discard) { str += "discard, " }
    if contains(.interlaced) { str += "interlaced, " }
    if contains(.topFieldFirst) { str += "topFieldFirst, " }
    if str.suffix(2) == ", " {
      str.removeLast(2)
    }
    str += "]"
    return str
  }
}
