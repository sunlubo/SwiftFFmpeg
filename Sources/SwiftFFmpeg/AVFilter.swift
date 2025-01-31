//
//  AVFilter.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/18.
//

import CFFmpeg

// MARK: - AVFilterPad

public struct AVFilterPad {
  let native: OpaquePointer
  let index: UInt32

  init(native: OpaquePointer, index: UInt32) {
    self.native = native
    self.index = index
  }

  /// The name of the filter pad.
  public var name: String {
    String(cString: avfilter_pad_get_name(native, Int32(index)))
  }

  /// The media type of the filter pad.
  public var mediaType: AVMediaType {
    AVMediaType(native: avfilter_pad_get_type(native, Int32(index)))
  }
}

extension AVFilterPad: CustomStringConvertible {

  public var description: String {
    "\(name) - \(mediaType))"
  }
}

// MARK: - AVFilter

typealias CAVFilter = CFFmpeg.AVFilter

public struct AVFilter {
  var native: UnsafePointer<CAVFilter>

  init(native: UnsafePointer<CAVFilter>) {
    self.native = native
  }

  /// Get a filter definition matching the given name.
  ///
  /// - Parameter name: the filter name to find
  /// - Returns: the filter definition, or `nil` if none found
  public init?(name: String) {
    guard let ptr = avfilter_get_by_name(name) else {
      return nil
    }
    self.native = ptr
  }

  /// The name of the filter.
  public var name: String {
    String(cString: native.pointee.name)
  }

  /// The inputs of the filter.
  ///
  /// `nil` if there are no (static) inputs.
  /// Instances of filters with `AVFilter.Flag.dynamicInputs` set may have more inputs
  /// than present in this list.
  public var inputs: [AVFilterPad]? {
    guard let start = native.pointee.inputs else {
      return nil
    }
    let count = avfilter_filter_pad_count(native, 0)
    let list = (0 ..< count).map({ AVFilterPad(native: start, index: $0) })
    return list
  }

  /// The outputs of the filter.
  ///
  /// `nil` if there are no (static) outputs.
  /// Instances of filters with `AVFilter.Flag.dynamicOutputs` set may have more outputs
  /// than present in this list.
  public var outputs: [AVFilterPad]? {
    guard let start = native.pointee.outputs else {
      return nil
    }
    let count = avfilter_filter_pad_count(native, 1)
    let list = (0 ..< count).map({ AVFilterPad(native: start, index: $0) })
    return list
  }

  /// The flags of the filter.
  public var flags: Flag {
    Flag(rawValue: native.pointee.flags)
  }

  /// Get all registered filters.
  public static var supportedFilters: [AVFilter] {
    var list = [AVFilter]()
    var state: UnsafeMutableRawPointer?
    while let filter = av_filter_iterate(&state) {
      list.append(AVFilter(native: filter))
    }
    return list
  }
}

extension AVFilter: CustomStringConvertible {

  public var description: String {
    "\(name): \(String(cString: native.pointee.description) ?? "")"
  }
}

// MARK: - AVFilter.Flag

extension AVFilter {
  public struct Flag: OptionSet {
    /// The number of the filter inputs is not determined just by `AVFilter.inputs`.
    /// The filter might add additional inputs during initialization depending on the
    /// options supplied to it.
    public static let dynamicInputs = Flag(rawValue: AVFILTER_FLAG_DYNAMIC_INPUTS)
    /// The number of the filter outputs is not determined just by `AVFilter.outputs`.
    /// The filter might add additional outputs during initialization depending on
    /// the options supplied to it.
    public static let dynamicOutputs = Flag(rawValue: AVFILTER_FLAG_DYNAMIC_OUTPUTS)
    /// The filter supports multithreading by splitting frames into multiple parts
    /// and processing them concurrently.
    public static let sliceThreads = Flag(rawValue: AVFILTER_FLAG_SLICE_THREADS)
    /// Some filters support a generic "enable" expression option that can be used
    /// to enable or disable a filter in the timeline. Filters supporting this
    /// option have this flag set. When the enable expression is false, the default
    /// no-op `filter_frame()` function is called in place of the `filter_frame()`
    /// callback defined on each input pad, thus the frame is passed unchanged to
    /// the next filters.
    public static let supportTimelineGeneric = Flag(
      rawValue: AVFILTER_FLAG_SUPPORT_TIMELINE_GENERIC)
    /// Same as `supportTimelineGeneric`, except that the filter will
    /// have its `filter_frame()` callback(s) called as usual even when the enable
    /// expression is false. The filter will disable filtering within the
    /// `filter_frame()` callback(s) itself, for example executing code depending on
    /// the `AVFilterContext->is_disabled` value.
    public static let supportTimelineInternal = Flag(
      rawValue: AVFILTER_FLAG_SUPPORT_TIMELINE_INTERNAL)
    /// Handy mask to test whether the filter supports or no the timeline feature
    /// (internally or generically).
    public static let supportTimeline = Flag(rawValue: AVFILTER_FLAG_SUPPORT_TIMELINE)

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
  }
}

extension AVFilter.Flag: CustomStringConvertible {
  public var description: String {
    var str = "["
    if contains(.dynamicInputs) { str += "dynamicInputs, " }
    if contains(.dynamicOutputs) { str += "dynamicOutputs, " }
    if contains(.sliceThreads) { str += "sliceThreads, " }
    if contains(.supportTimelineGeneric) { str += "supportTimelineGeneric, " }
    if contains(.supportTimelineInternal) { str += "supportTimelineInternal, " }
    if contains(.supportTimeline) { str += "supportTimeline, " }
    if str.suffix(2) == ", " {
      str.removeLast(2)
    }
    str += "]"
    return str
  }
}

extension AVFilter: AVOptionSupport {

  public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
    var tmp = native.pointee.priv_class
    return try withUnsafeMutablePointer(to: &tmp) { ptr in
      try body(ptr)
    }
  }
}

// MARK: - AVFilterContext

typealias CAVFilterContext = CFFmpeg.AVFilterContext

/// An instance of a filter.
public final class AVFilterContext {
  let native: UnsafeMutablePointer<CAVFilterContext>

  init(native: UnsafeMutablePointer<CAVFilterContext>) {
    self.native = native
  }

  /// Create a new filter instance in a filter graph.
  ///
  /// - Parameters:
  ///   - graph: graph in which the new filter will be used
  ///   - filter: the filter to create an instance of
  ///   - name: Name to give to the new instance (will be copied to `AVFilterContext.name`).
  ///     This may be used by the caller to identify different filters, libavfilter itself
  ///     assigns no semantics to this parameter. May be `nil`.
  /// - Returns: the context of the newly created filter instance (note that it is also
  ///   retrievable directly through `AVFilterGraph.filters` or with `avfilter_graph_get_filter()`).
  public init(graph: AVFilterGraph, filter: AVFilter, name: String? = nil) {
    self.native = avfilter_graph_alloc_filter(graph.native, filter.native, name)
  }

  /// The `AVFilter` of which this is an instance.
  public var filter: AVFilter {
    get { AVFilter(native: native.pointee.filter) }
    set { native.pointee.filter = newValue.native }
  }

  /// The name of this filter instance.
  public var name: String {
    String(cString: native.pointee.name)
  }

  /// The input links of this filter instance.
  public var inputs: [AVFilterLink] {
    var list = [AVFilterLink]()
    for i in 0 ..< inputCount {
      list.append(AVFilterLink(native: native.pointee.inputs[i]!))
    }
    return list
  }

  /// The number of input pads.
  public var inputCount: Int {
    Int(native.pointee.nb_inputs)
  }

  /// The output links of this filter instance.
  public var outputs: [AVFilterLink] {
    var list = [AVFilterLink]()
    for i in 0 ..< outputCount {
      list.append(AVFilterLink(native: native.pointee.outputs[i]!))
    }
    return list
  }

  /// The number of input pads.
  public var outputCount: Int {
    Int(native.pointee.nb_outputs)
  }

  /// The filtergraph this filter belongs to.
  public var graph: AVFilterGraph {
    AVFilterGraph(native: native.pointee.graph)
  }

  /// Initialize a filter with the supplied parameters.
  ///
  /// - Parameter args: Options to initialize the filter with.
  ///   This must be a ':'-separated list of options in the 'key=value' form.
  ///   May be `nil` if the options have been set directly using the AVOptions API
  ///   or there are no options that need to be set. The default is `nil`.
  /// - Throws: AVError
  public func initialize(args: String? = nil) throws {
    try throwIfFail(avfilter_init_str(native, args))
  }

  /// Initialize a filter with the supplied dictionary of options.
  ///
  /// - Note: This function and `avfilter_init_str()` do essentially the same thing,
  ///   the difference is in manner in which the options are passed. It is up to the
  ///   calling code to choose whichever is more preferable. The two functions also
  ///   behave differently when some of the provided options are not declared as
  ///   supported by the filter. In such a case, `avfilter_init_str()` will fail, but
  ///   this function will dump those extra options and continue as usual.
  ///
  /// - Parameter args: A Dictionary filled with options for this filter.
  /// - Throws: AVError
  public func initialize(args: [String: String]) throws {
    var pm: OpaquePointer? = args.avDict
    defer { av_dict_free(&pm) }

    try throwIfFail(avfilter_init_dict(native, &pm))

    dumpUnrecognizedOptions(pm)
  }

  /// Link two filters together.
  ///
  /// - Parameters:
  ///   - srcPad: The index of the output pad on the source filter. The default is 0.
  ///   - dst: The destination filter.
  ///   - dstPad: The index of the input pad on the destination filter. The default is 0.
  /// - Returns: The destination filter.
  /// - Throws: AVError
  @discardableResult
  public func link(
    srcPad: UInt = 0,
    dst: AVFilterContext,
    dstPad: UInt = 0
  ) throws -> AVFilterContext {
    try throwIfFail(avfilter_link(native, UInt32(srcPad), dst.native, UInt32(dstPad)))
    return dst
  }
}

extension AVFilterContext: AVClassSupport, AVOptionSupport {
  public static let `class` = AVClass(native: avfilter_get_class())

  public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
    try body(native)
  }
}

// MARK: - AVBufferSourceFlag

public struct AVBufferSourceFlag: OptionSet {
  /// Do not check for format changes.
  public static let noCheckFormat = AVBufferSourceFlag(
    rawValue: Int32(AV_BUFFERSRC_FLAG_NO_CHECK_FORMAT))
  // Immediately push the frame to the output.
  public static let push = AVBufferSourceFlag(rawValue: Int32(AV_BUFFERSRC_FLAG_PUSH))
  /// Keep a reference to the frame.
  /// If the frame if reference-counted, create a new reference; otherwise copy the frame data.
  public static let keepReference = AVBufferSourceFlag(
    rawValue: Int32(AV_BUFFERSRC_FLAG_KEEP_REF))

  public let rawValue: Int32

  public init(rawValue: Int32) { self.rawValue = rawValue }
}

extension AVBufferSourceFlag: CustomStringConvertible {
  public var description: String {
    var str = "["
    if contains(.noCheckFormat) { str += "noCheckFormat, " }
    if contains(.push) { str += "push, " }
    if contains(.keepReference) { str += "keepReference, " }
    if str.suffix(2) == ", " {
      str.removeLast(2)
    }
    str += "]"
    return str
  }
}

// MARK: - Buffer Source

extension AVFilterContext {

  /// Add a frame to the buffer source.
  ///
  /// By default, if the frame is reference-counted, this function will take ownership of
  /// the reference(s) and reset the frame. Otherwise the frame data will be copied.
  /// This can be controlled using the flags.
  ///
  /// If this function throws an error, the input frame is not touched.
  ///
  /// - Parameters:
  ///   - frame: a frame, or `nil` to mark EOF
  ///   - flags: a combination of `AVBufferSourceFlag` flags
  /// - Throws: AVError
  public func addFrame(_ frame: AVFrame?, flags: AVBufferSourceFlag = .init(rawValue: 0)) throws {
    try throwIfFail(av_buffersrc_add_frame_flags(native, frame?.native, flags.rawValue))
  }
}

// MARK: - AVBufferSinkFlag

public struct AVBufferSinkFlag: OptionSet {
  /// Tell av_buffersink_get_buffer_ref() to read video/samples buffer
  /// reference, but not remove it from the buffer. This is useful if you
  /// need only to read a video/samples buffer, without to fetch it.
  public static let peek = AVBufferSinkFlag(rawValue: Int32(AV_BUFFERSINK_FLAG_PEEK))
  /// Tell av_buffersink_get_buffer_ref() not to request a frame from its input.
  /// If a frame is already buffered, it is read (and removed from the buffer),
  /// but if no frame is present, return AVERROR(EAGAIN).
  public static let noRequest = AVBufferSinkFlag(rawValue: Int32(AV_BUFFERSINK_FLAG_NO_REQUEST))

  public let rawValue: Int32

  public init(rawValue: Int32) { self.rawValue = rawValue }
}

extension AVBufferSinkFlag: CustomStringConvertible {
  public var description: String {
    var str = "["
    if contains(.peek) { str += "peek, " }
    if contains(.noRequest) { str += "noRequest, " }
    if str.suffix(2) == ", " {
      str.removeLast(2)
    }
    str += "]"
    return str
  }
}

// MARK: - Buffer Sink

extension AVFilterContext {
  /// The media type of the buffer sink.
  public var mediaType: AVMediaType {
    AVMediaType(native: av_buffersink_get_type(native))
  }

  /// The timebase of the buffer sink.
  public var timebase: AVRational {
    av_buffersink_get_time_base(native)
  }

  /// The pixel format of the video buffer sink.
  public var pixelFormat: AVPixelFormat {
    AVPixelFormat(rawValue: av_buffersink_get_format(native))
  }

  /// The frame rate of the video buffer sink.
  public var frameRate: AVRational {
    av_buffersink_get_frame_rate(native)
  }

  /// The width of the video buffer sink.
  public var width: Int {
    Int(av_buffersink_get_w(native))
  }

  /// The height of the video buffer sink.
  public var height: Int {
    Int(av_buffersink_get_h(native))
  }

  /// The sample aspect ratio of the video buffer sink.
  public var sampleAspectRatio: AVRational {
    av_buffersink_get_sample_aspect_ratio(native)
  }

  /// The sample format of the audio buffer sink.
  public var sampleFormat: AVSampleFormat {
    AVSampleFormat(rawValue: av_buffersink_get_format(native))!
  }

  /// The sample rate of the audio buffer sink.
  public var sampleRate: Int {
    Int(av_buffersink_get_sample_rate(native))
  }

  /// The number of channels in the audio buffer sink.
  public var channelCount: Int {
    Int(av_buffersink_get_channels(native))
  }

  /// The channel layout of the audio buffer sink.
  public var channelLayout: AVChannelLayout? {
    var chl = AVChannelLayout()
    let r = av_buffersink_get_ch_layout(native, &chl)
    return r >= 0 ? chl : nil
  }

  /// Get a frame with filtered data from sink and put it in frame.
  ///
  /// - Parameters:
  ///   - frame: pointer to an allocated frame that will be filled with data.
  ///     The data must be freed using `av_frame_unref() / av_frame_free()`.
  ///   - flags: a combination of `AVBufferSinkFlag` flags
  /// - Throws:
  ///     - `AVError.tryAgain` if no frames are available at this point;
  ///       more input frames must be added to the filtergraph to get more output.
  ///     - `AVError.eof` if there will be no more output frames on this sink.
  ///     - A different `AVError` in other failure cases.
  public func getFrame(_ frame: AVFrame, flags: AVBufferSinkFlag = .init(rawValue: 0)) throws {
    try throwIfFail(av_buffersink_get_frame_flags(native, frame.native, flags.rawValue))
  }
}

// MARK: - AVFilterLink

typealias CAVFilterLink = CFFmpeg.AVFilterLink

/// A link between two filters. This contains pointers to the source and destination filters
/// between which this link exists, and the indexes of the pads involved.
/// In addition, this link also contains the parameters which have been negotiated and
/// agreed upon between the filter, such as image dimensions, format, etc.
public struct AVFilterLink {
  let native: UnsafeMutablePointer<CAVFilterLink>

  init(native: UnsafeMutablePointer<CAVFilterLink>) {
    self.native = native
  }

  /// The source filter.
  public var source: AVFilterContext {
    AVFilterContext(native: native.pointee.src)
  }

  /// The destination filter.
  public var destination: AVFilterContext {
    AVFilterContext(native: native.pointee.dst)
  }

  /// The filter's media type.
  public var mediaType: AVMediaType {
    AVMediaType(native: native.pointee.type)
  }

  /// Define the timebase used by the PTS of the frames/samples which will pass through this link.
  /// During the configuration stage, each filter is supposed to change only the output timebase,
  /// while the timebase of the input link is assumed to be an unchangeable property.
  public var timebase: AVRational {
    native.pointee.time_base
  }
}

// MARK: - Video

extension AVFilterLink {
  /// agreed upon pixel format
  public var pixelFormat: AVPixelFormat {
    AVPixelFormat(native.pointee.format)
  }

  /// agreed upon image width
  public var width: Int {
    Int(native.pointee.w)
  }

  /// agreed upon image height
  public var height: Int {
    Int(native.pointee.h)
  }

  /// agreed upon sample aspect ratio
  public var sampleAspectRatio: AVRational {
    native.pointee.sample_aspect_ratio
  }
}

// MARK: - Audio

extension AVFilterLink {
  /// agreed upon sample format
  public var sampleFormat: AVSampleFormat {
    AVSampleFormat(rawValue: native.pointee.format)!
  }

  /// channel layout of current buffer
  public var channelLayout: AVChannelLayout {
    native.pointee.ch_layout
  }

  /// samples per second
  public var sampleRate: Int {
    Int(native.pointee.sample_rate)
  }
}

// MARK: - AVFilterGraph

typealias CAVFilterGraph = CFFmpeg.AVFilterGraph

public final class AVFilterGraph {
  var native: UnsafeMutablePointer<CAVFilterGraph>!
  var owned: Bool = false

  init(native: UnsafeMutablePointer<CAVFilterGraph>) {
    self.native = native
  }

  /// Create a filter graph.
  public init() {
    self.native = avfilter_graph_alloc()
    self.owned = true
  }

  deinit {
    if owned {
      avfilter_graph_free(&native)
    }
  }

  /// The filter list in the graph.
  public var filters: [AVFilterContext] {
    var list = [AVFilterContext]()
    for i in 0 ..< filterCount {
      let filter = native.pointee.filters.advanced(by: i).pointee!
      list.append(AVFilterContext(native: filter))
    }
    return list
  }

  /// The number of filters in the graph.
  public var filterCount: Int {
    Int(native.pointee.nb_filters)
  }

  /// Create and add a filter instance into an existing graph.
  /// The filter instance is created from the filter filt and inited with the parameters.
  ///
  /// - Parameters:
  ///   - filter: the filter to create an instance of
  ///   - name: the instance name to give to the created filter instance
  ///   - args: Options to initialize the filter with. This must be a
  ///     ':'-separated list of options in the 'key=value' form.
  ///     May be NULL if the options have been set directly using the
  ///     AVOptions API or there are no options that need to be set.
  /// - Returns: newly created filter instance
  /// - Throws: AVError
  public func addFilter(_ filter: AVFilter, name: String, args: String? = nil) throws -> AVFilterContext {
    var ptr: UnsafeMutablePointer<CAVFilterContext>!
    let ret = avfilter_graph_create_filter(&ptr, filter.native, name, args, nil, native)
    try throwIfFail(ret)
    return AVFilterContext(native: ptr)
  }

  /// Add a graph described by a string to a graph.
  ///
  /// In the graph filters description,
  /// if the input label of the first filter is not specified, "in" is assumed;
  /// if the output label of the last filter is not specified, "out" is assumed.
  ///
  /// - Parameters:
  ///   - filters: string to be parsed
  ///   - inputs: pointer to a linked list to the inputs of the graph, may be `nil`.
  ///     If non-NULL, *inputs is updated to contain the list of open inputs
  ///     after the parsing, should be freed with avfilter_inout_free().
  ///   - outputs: pointer to a linked list to the outputs of the graph, may be NULL.
  ///     If non-NULL, *outputs is updated to contain the list of open outputs
  ///     after the parsing, should be freed with avfilter_inout_free().
  /// - Throws: AVError
  public func parse(filters: String, inputs: AVFilterInOut, outputs: AVFilterInOut) throws {
    inputs.owned = false
    outputs.owned = false
    var inputsPtr: UnsafeMutablePointer<CAVFilterInOut>? = inputs.native
    var outputPtr: UnsafeMutablePointer<CAVFilterInOut>? = outputs.native
    try throwIfFail(avfilter_graph_parse_ptr(native, filters, &inputsPtr, &outputPtr, nil))
  }

  /// Check validity and configure all the links and formats in the graph.
  ///
  /// - Throws: AVError
  public func configure() throws {
    try throwIfFail(avfilter_graph_config(native, nil))
  }
}

extension AVFilterGraph: CustomStringConvertible {

  public var description: String {
    let cstr = avfilter_graph_dump(native, nil)
    defer { av_free(cstr) }
    return String(cString: cstr)!
  }
}

extension AVFilterGraph: AVOptionSupport {

  public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
    try body(native)
  }
}

// MARK: - AVFilterInOut

typealias CAVFilterInOut = CFFmpeg.AVFilterInOut

/// A linked-list of the inputs/outputs of the filter chain.
///
/// This is mainly useful for `avfilter_graph_parse()` / `avfilter_graph_parse2()`,
/// where it is used to communicate open (unlinked) inputs and outputs from and
/// to the caller.
/// This struct specifies, per each not connected pad contained in the graph, the
/// filter context and the pad index required for establishing a link.
public final class AVFilterInOut {
  var native: UnsafeMutablePointer<CAVFilterInOut>!
  var owned: Bool = false

  init(native: UnsafeMutablePointer<CAVFilterInOut>) {
    self.native = native
  }

  /// Create a single `AVFilterInOut` entry.
  public init() {
    self.native = avfilter_inout_alloc()
    self.owned = true
  }

  deinit {
    if owned {
      avfilter_inout_free(&native)
    }
  }

  /// The unique name for this input/output in the list.
  public var name: String {
    get { String(cString: native.pointee.name) }
    set { native.pointee.name = av_strdup(newValue) }
  }

  /// The filter context associated to this input/output.
  public var filterContext: AVFilterContext {
    get { AVFilterContext(native: native.pointee.filter_ctx) }
    set { native.pointee.filter_ctx = newValue.native }
  }

  /// The index of the filter context pad to use for linking.
  public var padIndex: Int {
    get { Int(native.pointee.pad_idx) }
    set { native.pointee.pad_idx = Int32(newValue) }
  }

  /// The next input/input in the list, `nil` if this is the last.
  public var next: AVFilterInOut? {
    get { native.pointee.next.map(AVFilterInOut.init(native:)) }
    set { native.pointee.next = newValue?.native }
  }
}
