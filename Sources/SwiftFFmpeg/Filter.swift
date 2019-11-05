//
//  Filter.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/18.
//

#if swift(>=4.2)

import CFFmpeg

// MARK: - FilterPad

public struct FilterPad {
    let cPadsPtr: OpaquePointer
    let index: Int32

    init(cPadsPtr: OpaquePointer, index: Int32) {
        self.cPadsPtr = cPadsPtr
        self.index = index
    }

    /// The name of the filter pad.
    public var name: String {
        String(cString: avfilter_pad_get_name(cPadsPtr, index))
    }

    /// The media type of the filter pad.
    public var mediaType: MediaType {
        avfilter_pad_get_type(cPadsPtr, index)
    }
}

extension FilterPad: CustomStringConvertible {

    public var description: String {
        "\(name) - \(mediaType))"
    }
}

// MARK: - Filter

typealias CAVFilter = CFFmpeg.AVFilter

public struct Filter {
    let cFilterPtr: UnsafePointer<CAVFilter>
    var cFilter: CAVFilter { cFilterPtr.pointee }

    init(cFilterPtr: UnsafePointer<CAVFilter>) {
        self.cFilterPtr = cFilterPtr
    }

    /// Get a filter definition matching the given name.
    ///
    /// - Parameter name: the filter name to find
    /// - Returns: the filter definition, or `nil` if none found
    public init?(name: String) {
        guard let filterPtr = avfilter_get_by_name(name) else {
            return nil
        }
        self.cFilterPtr = filterPtr
    }

    /// The name of the filter.
    public var name: String {
        String(cString: cFilter.name)
    }

    /// The inputs of the filter.
    ///
    /// `nil` if there are no (static) inputs.
    /// Instances of filters with `AVFilter.Flag.dynamicInputs` set may have more inputs
    /// than present in this list.
    public var inputs: [FilterPad]? {
        guard let start = cFilter.inputs else {
            return nil
        }
        let count = avfilter_pad_count(cFilter.inputs)
        let list = (0..<count).map({ FilterPad(cPadsPtr: start, index: $0) })
        return list
    }

    /// The outputs of the filter.
    ///
    /// `nil` if there are no (static) outputs.
    /// Instances of filters with `AVFilter.Flag.dynamicOutputs` set may have more outputs
    /// than present in this list.
    public var outputs: [FilterPad]? {
        guard let start = cFilter.outputs else {
            return nil
        }
        let count = avfilter_pad_count(cFilter.outputs)
        let list = (0..<count).map({ FilterPad(cPadsPtr: start, index: $0) })
        return list
    }

    /// The flags of the filter.
    public var flags: Flag {
        Flag(rawValue: cFilter.flags)
    }

    /// Get all registered filters.
    public static var supportedFilters: [Filter] {
        var list = [Filter]()
        var state: UnsafeMutableRawPointer?
        while let filter = av_filter_iterate(&state) {
            list.append(Filter(cFilterPtr: filter))
        }
        return list
    }
}

extension Filter: CustomStringConvertible {

    public var description: String {
        "\(name): \(String(cString: cFilter.description) ?? "")"
    }
}

// MARK: - Filter.Flag

extension Filter {

    public struct Flag: OptionSet {
        /// The number of the filter inputs is not determined just by `Filter.inputs`.
        /// The filter might add additional inputs during initialization depending on the
        /// options supplied to it.
        public static let dynamicInputs = Flag(rawValue: AVFILTER_FLAG_DYNAMIC_INPUTS)
        /// The number of the filter outputs is not determined just by `Filter.outputs`.
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
        public static let supportTimelineGeneric = Flag(rawValue: AVFILTER_FLAG_SUPPORT_TIMELINE_GENERIC)
        /// Same as `supportTimelineGeneric`, except that the filter will
        /// have its `filter_frame()` callback(s) called as usual even when the enable
        /// expression is false. The filter will disable filtering within the
        /// `filter_frame()` callback(s) itself, for example executing code depending on
        /// the `FilterContext->is_disabled` value.
        public static let supportTimelineInternal = Flag(rawValue: AVFILTER_FLAG_SUPPORT_TIMELINE_INTERNAL)
        /// Handy mask to test whether the filter supports or no the timeline feature
        /// (internally or generically).
        public static let supportTimeline = Flag(rawValue: AVFILTER_FLAG_SUPPORT_TIMELINE)

        public let rawValue: Int32

        public init(rawValue: Int32) { self.rawValue = rawValue }
    }
}

extension Filter.Flag: CustomStringConvertible {

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

extension Filter: OptionSupport {

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        var tmp = cFilter.priv_class
        return try withUnsafeMutablePointer(to: &tmp) { ptr in
            try body(ptr)
        }
    }
}

// MARK: - FilterContext

typealias CAVFilterContext = CFFmpeg.AVFilterContext

/// An instance of a filter.
public final class FilterContext {
    let cContextPtr: UnsafeMutablePointer<CAVFilterContext>
    var cContext: CAVFilterContext { cContextPtr.pointee }

    init(cContextPtr: UnsafeMutablePointer<CAVFilterContext>) {
        self.cContextPtr = cContextPtr
    }

    /// Create a new filter instance in a filter graph.
    ///
    /// - Parameters:
    ///   - graph: graph in which the new filter will be used
    ///   - filter: the filter to create an instance of
    ///   - name: Name to give to the new instance (will be copied to `FilterContext.name`).
    ///     This may be used by the caller to identify different filters, libavfilter itself
    ///     assigns no semantics to this parameter. May be `nil`.
    /// - Returns: the context of the newly created filter instance (note that it is also
    ///   retrievable directly through `AVFilterGraph.filters` or with `avfilter_graph_get_filter()`).
    public init(graph: FilterGraph, filter: Filter, name: String? = nil) {
        guard let ctxPtr = avfilter_graph_alloc_filter(graph.cGraphPtr, filter.cFilterPtr, name) else {
            abort("avfilter_graph_alloc_filter")
        }
        self.cContextPtr = ctxPtr
    }

    /// The `AVFilter` of which this is an instance.
    public var filter: Filter {
        get { Filter(cFilterPtr: cContext.filter) }
        set { cContextPtr.pointee.filter = newValue.cFilterPtr }
    }

    /// The name of this filter instance.
    public var name: String {
        String(cString: cContext.name)
    }

    /// The input links of this filter instance.
    public var inputs: [FilterLink] {
        var list = [FilterLink]()
        for i in 0..<inputCount {
            list.append(FilterLink(cLinkPtr: cContext.inputs[i]!))
        }
        return list
    }

    /// The number of input pads.
    public var inputCount: Int {
        Int(cContext.nb_inputs)
    }

    /// The output links of this filter instance.
    public var outputs: [FilterLink] {
        var list = [FilterLink]()
        for i in 0..<outputCount {
            list.append(FilterLink(cLinkPtr: cContext.outputs[i]!))
        }
        return list
    }

    /// The number of input pads.
    public var outputCount: Int {
        Int(cContext.nb_outputs)
    }

    /// The filtergraph this filter belongs to.
    public var graph: FilterGraph {
        FilterGraph(cGraphPtr: cContext.graph)
    }

    /// Initialize a filter with the supplied parameters.
    ///
    /// - Parameter args: Options to initialize the filter with.
    ///   This must be a ':'-separated list of options in the 'key=value' form.
    ///   May be `nil` if the options have been set directly using the AVOptions API
    ///   or there are no options that need to be set. The default is `nil`.
    /// - Throws: AVError
    public func initialize(args: String? = nil) throws {
        try throwIfFail(avfilter_init_str(cContextPtr, args))
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
        var pm: OpaquePointer? = args.toAVDict()
        defer { av_dict_free(&pm) }

        try throwIfFail(avfilter_init_dict(cContextPtr, &pm))

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
        dst: FilterContext,
        dstPad: UInt = 0
    ) throws -> FilterContext {
        try throwIfFail(avfilter_link(cContextPtr, UInt32(srcPad), dst.cContextPtr, UInt32(dstPad)))
        return dst
    }
}

extension FilterContext: ClassSupport, OptionSupport {
    public static let `class` = Class(cClassPtr: avfilter_get_class())

    public func withUnsafeObjectPointer<T>(
        _ body: (UnsafeMutableRawPointer) throws -> T
    ) rethrows -> T {
        try body(cContextPtr)
    }
}

// MARK: - BufferSourceFlag

public struct BufferSourceFlag: OptionSet {
    /// Do not check for format changes.
    public static let noCheckFormat = BufferSourceFlag(rawValue: Int32(AV_BUFFERSRC_FLAG_NO_CHECK_FORMAT))
    // Immediately push the frame to the output.
    public static let push = BufferSourceFlag(rawValue: Int32(AV_BUFFERSRC_FLAG_PUSH))
    /// Keep a reference to the frame.
    /// If the frame if reference-counted, create a new reference; otherwise copy the frame data.
    public static let keepReference = BufferSourceFlag(rawValue: Int32(AV_BUFFERSRC_FLAG_KEEP_REF))

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
}

extension BufferSourceFlag: CustomStringConvertible {

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

extension FilterContext {

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
    ///   - flags: a combination of `BufferSourceFlag` flags
    /// - Throws: AVError
    public func addFrame(_ frame: Frame?, flags: BufferSourceFlag = .init(rawValue: 0)) throws {
        try throwIfFail(av_buffersrc_add_frame_flags(cContextPtr, frame?.cFramePtr, flags.rawValue))
    }
}

// MARK: - BufferSinkFlag

public struct BufferSinkFlag: OptionSet {
    /// Tell av_buffersink_get_buffer_ref() to read video/samples buffer
    /// reference, but not remove it from the buffer. This is useful if you
    /// need only to read a video/samples buffer, without to fetch it.
    public static let peek = BufferSinkFlag(rawValue: Int32(AV_BUFFERSINK_FLAG_PEEK))
    /// Tell av_buffersink_get_buffer_ref() not to request a frame from its input.
    /// If a frame is already buffered, it is read (and removed from the buffer),
    /// but if no frame is present, return AVERROR(EAGAIN).
    public static let noRequest = BufferSinkFlag(rawValue: Int32(AV_BUFFERSINK_FLAG_NO_REQUEST))

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
}

extension BufferSinkFlag: CustomStringConvertible {

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

extension FilterContext {

    /// The media type of the buffer sink.
    public var mediaType: MediaType {
        av_buffersink_get_type(cContextPtr)
    }

    /// The timebase of the buffer sink.
    public var timebase: Rational {
        av_buffersink_get_time_base(cContextPtr)
    }

    /// The pixel format of the video buffer sink.
    public var pixelFormat: PixelFormat {
        PixelFormat(rawValue: av_buffersink_get_format(cContextPtr))
    }

    /// The frame rate of the video buffer sink.
    public var frameRate: Rational {
        av_buffersink_get_frame_rate(cContextPtr)
    }

    /// The width of the video buffer sink.
    public var width: Int {
        Int(av_buffersink_get_w(cContextPtr))
    }

    /// The height of the video buffer sink.
    public var height: Int {
        Int(av_buffersink_get_h(cContextPtr))
    }

    /// The sample aspect ratio of the video buffer sink.
    public var sampleAspectRatio: Rational {
        av_buffersink_get_sample_aspect_ratio(cContextPtr)
    }

    /// The sample format of the audio buffer sink.
    public var sampleFormat: SampleFormat {
        SampleFormat(rawValue: av_buffersink_get_format(cContextPtr))
    }

    /// The sample rate of the audio buffer sink.
    public var sampleRate: Int {
        Int(av_buffersink_get_sample_rate(cContextPtr))
    }

    /// The number of channels in the audio buffer sink.
    public var channelCount: Int {
        Int(av_buffersink_get_channels(cContextPtr))
    }

    /// The channel layout of the audio buffer sink.
    public var channelLayout: ChannelLayout {
        ChannelLayout(rawValue: av_buffersink_get_channel_layout(cContextPtr))
    }

    /// Get a frame with filtered data from sink and put it in frame.
    ///
    /// - Parameters:
    ///   - frame: pointer to an allocated frame that will be filled with data.
    ///     The data must be freed using `av_frame_unref() / av_frame_free()`.
    ///   - flags: a combination of `BufferSinkFlag` flags
    /// - Throws:
    ///     - `AVError.tryAgain` if no frames are available at this point;
    ///       more input frames must be added to the filtergraph to get more output.
    ///     - `AVError.eof` if there will be no more output frames on this sink.
    ///     - A different `AVError` in other failure cases.
    public func getFrame(_ frame: Frame, flags: BufferSinkFlag = .init(rawValue: 0)) throws {
        try throwIfFail(av_buffersink_get_frame_flags(cContextPtr, frame.cFramePtr, flags.rawValue))
    }
}

// MARK: - FilterLink

typealias CAVFilterLink = CFFmpeg.AVFilterLink

/// A link between two filters. This contains pointers to the source and destination filters
/// between which this link exists, and the indexes of the pads involved.
/// In addition, this link also contains the parameters which have been negotiated and
/// agreed upon between the filter, such as image dimensions, format, etc.
public struct FilterLink {
    let cLinkPtr: UnsafeMutablePointer<CAVFilterLink>

    init(cLinkPtr: UnsafeMutablePointer<CAVFilterLink>) {
        self.cLinkPtr = cLinkPtr
    }

    /// The source filter.
    public var source: FilterContext {
        FilterContext(cContextPtr: cLinkPtr.pointee.src)
    }

    /// The destination filter.
    public var destination: FilterContext {
        FilterContext(cContextPtr: cLinkPtr.pointee.dst)
    }

    /// The filter's media type.
    public var mediaType: MediaType {
        cLinkPtr.pointee.type
    }

    /// Define the timebase used by the PTS of the frames/samples which will pass through this link.
    /// During the configuration stage, each filter is supposed to change only the output timebase,
    /// while the timebase of the input link is assumed to be an unchangeable property.
    public var timebase: Rational {
        cLinkPtr.pointee.time_base
    }
}

// MARK: - Video

extension FilterLink {

    /// agreed upon pixel format
    public var pixelFormat: PixelFormat {
        PixelFormat(cLinkPtr.pointee.format)
    }

    /// agreed upon image width
    public var width: Int {
        Int(cLinkPtr.pointee.w)
    }

    /// agreed upon image height
    public var height: Int {
        Int(cLinkPtr.pointee.h)
    }

    /// agreed upon sample aspect ratio
    public var sampleAspectRatio: Rational {
        cLinkPtr.pointee.sample_aspect_ratio
    }
}

// MARK: - Audio

extension FilterLink {

    /// agreed upon sample format
    public var sampleFormat: SampleFormat {
        SampleFormat(cLinkPtr.pointee.format)
    }

    /// channel layout of current buffer
    public var channelLayout: ChannelLayout {
        ChannelLayout(rawValue: cLinkPtr.pointee.channel_layout)
    }

    /// samples per second
    public var sampleRate: Int {
        Int(cLinkPtr.pointee.sample_rate)
    }
}

// MARK: - FilterGraph

typealias CAVFilterGraph = CFFmpeg.AVFilterGraph

public final class FilterGraph {
    let cGraphPtr: UnsafeMutablePointer<CAVFilterGraph>
    var cGraph: CAVFilterGraph { cGraphPtr.pointee }

    init(cGraphPtr: UnsafeMutablePointer<CAVFilterGraph>) {
        self.cGraphPtr = cGraphPtr
    }

    /// Create a filter graph.
    public init() {
        guard let ptr = avfilter_graph_alloc() else {
            abort("avfilter_graph_alloc")
        }
        self.cGraphPtr = ptr
    }

    /// The filter list in the graph.
    public var filters: [FilterContext] {
        var list = [FilterContext]()
        for i in 0..<filterCount {
            let filter = cGraph.filters.advanced(by: i).pointee!
            list.append(FilterContext(cContextPtr: filter))
        }
        return list
    }

    /// The number of filters in the graph.
    public var filterCount: Int {
        Int(cGraph.nb_filters)
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
    public func addFilter(_ filter: Filter, name: String, args: String? = nil) throws -> FilterContext {
        var ctxPtr: UnsafeMutablePointer<CAVFilterContext>!
        let ret = avfilter_graph_create_filter(&ctxPtr, filter.cFilterPtr, name, args, nil, cGraphPtr)
        try throwIfFail(ret)
        return FilterContext(cContextPtr: ctxPtr)
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
    public func parse(filters: String, inputs: FilterInOut, outputs: FilterInOut) throws {
        inputs.freeWhenDone = false
        outputs.freeWhenDone = false
        var inputsPtr: UnsafeMutablePointer<CAVFilterInOut>? = inputs.cInOutPtr
        var outputPtr: UnsafeMutablePointer<CAVFilterInOut>? = outputs.cInOutPtr
        try throwIfFail(avfilter_graph_parse_ptr(cGraphPtr, filters, &inputsPtr, &outputPtr, nil))
    }

    /// Check validity and configure all the links and formats in the graph.
    ///
    /// - Throws: AVError
    public func configure() throws {
        try throwIfFail(avfilter_graph_config(cGraphPtr, nil))
    }

    deinit {
        var pb: UnsafeMutablePointer<CAVFilterGraph>? = cGraphPtr
        avfilter_graph_free(&pb)
    }
}

extension FilterGraph: CustomStringConvertible {

    public var description: String {
        let cstr = avfilter_graph_dump(cGraphPtr, nil)
        defer { av_free(cstr) }
        return String(cString: cstr)!
    }
}

extension FilterGraph: OptionSupport {

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        try body(cGraphPtr)
    }
}

// MARK: - FilterInOut

typealias CAVFilterInOut = CFFmpeg.AVFilterInOut

/// A linked-list of the inputs/outputs of the filter chain.
///
/// This is mainly useful for `avfilter_graph_parse()` / `avfilter_graph_parse2()`,
/// where it is used to communicate open (unlinked) inputs and outputs from and
/// to the caller.
/// This struct specifies, per each not connected pad contained in the graph, the
/// filter context and the pad index required for establishing a link.
public final class FilterInOut {
    let cInOutPtr: UnsafeMutablePointer<CAVFilterInOut>
    var cInOut: CAVFilterInOut { cInOutPtr.pointee }

    var freeWhenDone: Bool = false

    init(cInOutPtr: UnsafeMutablePointer<CAVFilterInOut>) {
        self.cInOutPtr = cInOutPtr
    }

    /// Create a single `FilterInOut` entry.
    public init() {
        guard let inOutPtr = avfilter_inout_alloc() else {
            abort("avfilter_inout_alloc")
        }
        self.cInOutPtr = inOutPtr
        self.freeWhenDone = true
    }

    /// The unique name for this input/output in the list.
    public var name: String {
        get { String(cString: cInOut.name) }
        set { cInOutPtr.pointee.name = av_strdup(newValue) }
    }

    /// The filter context associated to this input/output.
    public var filterContext: FilterContext {
        get { FilterContext(cContextPtr: cInOut.filter_ctx) }
        set { cInOutPtr.pointee.filter_ctx = newValue.cContextPtr }
    }

    /// The index of the filter context pad to use for linking.
    public var padIndex: Int {
        get { Int(cInOut.pad_idx) }
        set { cInOutPtr.pointee.pad_idx = Int32(newValue) }
    }

    /// The next input/input in the list, `nil` if this is the last.
    public var next: FilterInOut? {
        get {
            if let ptr = cInOut.next {
                return FilterInOut(cInOutPtr: ptr)
            }
            return nil
        }
        set { cInOutPtr.pointee.next = newValue?.cInOutPtr }
    }

    deinit {
        if freeWhenDone {
            var pb: UnsafeMutablePointer<CAVFilterInOut>? = cInOutPtr
            avfilter_inout_free(&pb)
        }
    }
}
#endif
