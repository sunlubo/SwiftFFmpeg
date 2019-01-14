//
//  SwrContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/6.
//

import CFFmpeg

public final class SwrContext {
    let cContextPtr: OpaquePointer

    /// Create `SwrContext`.
    ///
    /// If you use this function you will need to set the parameters (manually or with `setOptions`)
    /// before calling `initialize`.
    public init() {
        guard let ctxPtr = swr_alloc() else {
            fatalError("swr_alloc")
        }
        self.cContextPtr = ctxPtr
    }

    /// Create `SwrContext` if needed and set/reset common parameters.
    ///
    /// - Parameters:
    ///   - dstChannelLayout: output channel layout
    ///   - dstSampleFormat: output sample format
    ///   - dstSampleRate: output sample rate (frequency in Hz)
    ///   - srcChannelLayout: input channel layout
    ///   - srcSampleFormat: input sample format
    ///   - srcSampleRate: input sample rate (frequency in Hz)
    public init(
        dstChannelLayout: AVChannelLayout,
        dstSampleFormat: AVSampleFormat,
        dstSampleRate: Int,
        srcChannelLayout: AVChannelLayout,
        srcSampleFormat: AVSampleFormat,
        srcSampleRate: Int
    ) {
        cContextPtr = swr_alloc_set_opts(
            nil,
            Int64(dstChannelLayout.rawValue),
            dstSampleFormat,
            Int32(dstSampleRate),
            Int64(srcChannelLayout.rawValue),
            srcSampleFormat,
            Int32(srcSampleRate),
            0,
            nil
        )
    }

    /// A Boolean value indicating whether the context has been initialized or not.
    public var isInitialized: Bool {
        return swr_is_initialized(cContextPtr) > 0
    }

    /// Set/reset common parameters.
    ///
    /// - Parameters:
    ///   - dstChannelLayout: output channel layout
    ///   - dstSampleFormat: output sample format
    ///   - dstSampleRate: output sample rate (frequency in Hz)
    ///   - srcChannelLayout: input channel layout
    ///   - srcSampleFormat: input sample format
    ///   - srcSampleRate: input sample rate (frequency in Hz)
    ///
    /// - Throws: AVError
    public func setOptions(
        dstChannelLayout: AVChannelLayout,
        dstSampleFormat: AVSampleFormat,
        dstSampleRate: Int,
        srcChannelLayout: AVChannelLayout,
        srcSampleFormat: AVSampleFormat,
        srcSampleRate: Int
    ) throws {
        let ptr = swr_alloc_set_opts(
            cContextPtr,
            Int64(dstChannelLayout.rawValue),
            dstSampleFormat,
            Int32(dstSampleRate),
            Int64(srcChannelLayout.rawValue),
            srcSampleFormat,
            Int32(srcSampleRate),
            0,
            nil
        )
        if ptr == nil {
            throw AVError.invalidArgument
        }
    }

    /// Initialize context after user parameters have been set.
    ///
    /// - Throws: AVError
    public func initialize() throws {
        try throwIfFail(swr_init(cContextPtr))
    }

    /// Closes the context so that `isInitialized` returns `false`.
    ///
    /// The context can be brought back to life by running `initialize`,
    /// `initialize` can also be used without `close`.
    /// This function is mainly provided for simplifying the usecase
    /// where one tries to support libavresample and libswresample.
    public func close() {
        swr_close(cContextPtr)
    }

    /// Gets the delay the next input sample will experience relative to the next output sample.
    ///
    /// - Parameter timebase: timebase in which the returned delay will be
    ///   - if it's set to 1 the returned delay is in seconds
    ///   - if it's set to 1000 the returned delay is in milliseconds
    ///   - if it's set to the input sample rate then the returned delay is in input samples
    ///   - if it's set to the output sample rate then the returned delay is in output samples
    ///   - if it's the least common multiple of `in_sample_rate` and
    ///     `out_sample_rate` then an exact rounding-free delay will be returned
    /// - Returns: the delay in 1 / base units.
    public func getDelay(_ timebase: Int64) -> Int {
        return Int(swr_get_delay(cContextPtr, timebase))
    }

    /// Find an upper bound on the number of samples that the next `convert` call will output,
    /// if called with `sampleCount` of input samples.
    /// This depends on the internal state, and anything changing the internal state
    /// (like further `convert` calls) will may change the number of samples
    /// `getOutSamples` returns for the same number of input samples.
    ///
    /// - Note: any call to swr_inject_silence(), swr_convert(), swr_next_pts()
    ///   or swr_set_compensation() invalidates this limit
    ///
    /// - Note: it is recommended to pass the correct available buffer size to all functions
    ///   like `convert` even if `getOutSamples` indicates that less would be used.
    ///
    /// - Parameter sampleCount: number of input samples
    /// - Returns: an upper bound on the number of samples that the next `convert`
    ///   will output or a negative value to indicate an error
    ////
    public func getOutSamples(_ sampleCount: Int64) throws -> Int {
        let ret = swr_get_out_samples(cContextPtr, Int32(sampleCount))
        try throwIfFail(ret)
        return Int()
    }

    /// Convert audio.
    ///
    /// `dst` and `dstCount` can be set to 0 to flush the last few samples out at the end.
    ///
    /// If more input is provided than output space, then the input will be buffered.
    /// You can avoid this buffering by using `getOutSamples` to retrieve an upper bound
    /// on the required number of output samples for the given number of input samples.
    /// Conversion will run directly without copying whenever possible.
    ///
    /// - Parameters:
    ///   - dst: output buffers, only the first one need be set in case of packed audio
    ///   - dstCount: amount of space available for output in samples per channel
    ///   - src: input buffers, only the first one need to be set in case of packed audio
    ///   - srcCount: number of input samples available in one channel
    /// - Returns: number of samples output per channel
    /// - Throws: AVError
    @discardableResult
    public func convert(
        dst: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        dstCount: Int,
        src: UnsafeMutablePointer<UnsafePointer<UInt8>?>,
        srcCount: Int
    ) throws -> Int {
        let ret = swr_convert(cContextPtr, dst, Int32(dstCount), src, Int32(srcCount))
        try throwIfFail(ret)
        return Int(ret)
    }

    /// Configure or reconfigure the `SwrContext` using the information provided by the `AVFrame`s.
    ///
    /// The original resampling context is reset even on failure.
    /// The function calls `close` internally if the context is open.
    ///
    /// - SeeAlso: `close`
    ///
    /// - Parameters:
    ///   - output: output AVFrame
    ///   - input: input AVFrame
    /// - Throws: AVError
    public func config(output: AVFrame, input: AVFrame) throws {
        let ret = swr_config_frame(cContextPtr, output.cFramePtr, input.cFramePtr)
        try throwIfFail(ret)
    }

    /// Convert the samples in the input `AVFrame` and write them to the output `AVFrame`.
    ///
    /// Input and output `AVFrame`s must have __channel layout__, __sample rate__ and
    /// __format__ set.
    ///
    /// If the output `AVFrame` does not have the data pointers allocated the `nb_samples`
    /// field will be set using av_frame_get_buffer() is called to allocate the frame.
    ///
    /// The output `AVFrame` can be `nil` or have fewer allocated samples than required.
    /// In this case, any remaining samples not written to the output will be added
    /// to an internal FIFO buffer, to be returned at the next call to this function
    /// or to `convert`.
    ///
    /// If converting sample rate, there may be data remaining in the internal
    /// resampling delay buffer. `getDelay` tells the number of remaining samples.
    /// To get this data as output, call this function or `convert` with `nil` input.
    ///
    /// If the `SwrContext` configuration does not match the output and
    /// input `AVFrame` settings the conversion does not take place and depending on
    /// which `AVFrame` is not matching `AVError.outputChanged`, `AVError.inputChanged`
    /// or the result of a bitwise-OR of them is returned.
    ///
    /// - Parameters:
    ///   - output: output AVFrame
    ///   - input: input AVFrame
    /// - Throws: AVError
    public func convert(output: AVFrame, input: AVFrame) throws {
        let ret = swr_convert_frame(cContextPtr, output.cFramePtr, input.cFramePtr)
        try throwIfFail(ret)
    }

    deinit {
        var ptr: OpaquePointer? = cContextPtr
        swr_free(&ptr)
    }
}

extension SwrContext: AVClassSupport {
    public static let `class` = AVClass(cClassPtr: swr_get_class())

    public func withUnsafeClassObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        return try body(UnsafeMutableRawPointer(cContextPtr))
    }
}

extension SwrContext: AVOptionAccessor {

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        return try body(UnsafeMutableRawPointer(cContextPtr))
    }
}
