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
    /// If you use this function you will need to set the parameters before calling `initialize()`.
    public init() {
        guard let ctxPtr = swr_alloc() else {
            abort("swr_alloc")
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
        swr_is_initialized(cContextPtr) > 0
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
    /// The context can be brought back to life by running `initialize()`,
    /// `initialize()` can also be used without `close()`.
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
        Int(swr_get_delay(cContextPtr, timebase))
    }

    /// Find an upper bound on the number of samples that the next `convert(dst:dstCount:src:srcCount:)`
    /// call will output, if called with `sampleCount` of input samples.
    /// This depends on the internal state, and anything changing the internal state
    /// (like further `convert(dst:dstCount:src:srcCount:)` calls) will may change the number of samples
    /// `getOutSamples(_:)` returns for the same number of input samples.
    ///
    /// - Note: any call to swr_inject_silence(), swr_convert(), swr_next_pts()
    ///   or swr_set_compensation() invalidates this limit
    ///
    /// - Note: it is recommended to pass the correct available buffer size to all functions like
    ///   `convert(dst:dstCount:src:srcCount:)` even if `getOutSamples(_:)` indicates that less  would be used.
    ///
    /// - Parameter sampleCount: number of input samples
    /// - Returns: an upper bound on the number of samples that the next `convert(dst:dstCount:src:srcCount:)`
    ///   will output
    /// - Throws: AVError
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
    /// You can avoid this buffering by using `getOutSamples(_:)` to retrieve an upper bound
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

    deinit {
        var ptr: OpaquePointer? = cContextPtr
        swr_free(&ptr)
    }
}

extension SwrContext: AVClassSupport, AVOptionSupport {
    public static let `class` = AVClass(cClassPtr: swr_get_class())

    public func withUnsafeObjectPointer<T>(
        _ body: (UnsafeMutableRawPointer) throws -> T
    ) rethrows -> T {
        try body(UnsafeMutableRawPointer(cContextPtr))
    }
}
