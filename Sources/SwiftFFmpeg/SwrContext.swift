//
//  SwrContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/6.
//

import CFFmpeg

public final class SwrContext {
    public static let `class` = AVClass(cClassPtr: swr_get_class())

    let cContext: OpaquePointer

    /// Allocate SwrContext.
    ///
    /// If you use this function you will need to set the parameters (manually or with swr_alloc_set_opts())
    /// before calling swr_init().
    public init() {
        cContext = swr_alloc()
    }

    /// Allocate SwrContext if needed and set/reset common parameters.
    ///
    /// - Parameters:
    ///   - dstChannelLayout: output channel layout
    ///   - dstSampleFmt: output sample format
    ///   - dstSampleRate: output sample rate (frequency in Hz)
    ///   - srcChannelLayout: input channel layout
    ///   - srcSampleFmt: input sample format
    ///   - srcSampleRate: input sample rate (frequency in Hz)
    public init(
        dstChannelLayout: AVChannelLayout,
        dstSampleFmt: AVSampleFormat,
        dstSampleRate: Int,
        srcChannelLayout: AVChannelLayout,
        srcSampleFmt: AVSampleFormat,
        srcSampleRate: Int
    ) {
        cContext = swr_alloc_set_opts(
            nil,
            Int64(dstChannelLayout.rawValue),
            dstSampleFmt,
            Int32(dstSampleRate),
            Int64(srcChannelLayout.rawValue),
            srcSampleFmt,
            Int32(srcSampleRate),
            0,
            nil
        )
    }

    /// A Boolean value indicating whether the context has been initialized or not.
    public var isInitialized: Bool {
        return swr_is_initialized(cContext) > 0
    }

    /// Initialize context after user parameters have been set.
    ///
    /// - Throws: AVError
    public func initialize() throws {
        try throwIfFail(swr_init(cContext))
    }

    /// Gets the delay the next input sample will experience relative to the next output sample.
    ///
    /// - Parameter timebase: timebase in which the returned delay will be
    ///   - if it's set to 1 the returned delay is in seconds
    ///   - if it's set to 1000 the returned delay is in milliseconds
    ///   - if it's set to the input sample rate then the returned delay is in input samples
    ///   - if it's set to the output sample rate then the returned delay is in output samples
    ///   - if it's the least common multiple of in_sample_rate and
    ///     out_sample_rate then an exact rounding-free delay will be eturned
    /// - Returns: the delay in 1 / base units.
    public func getDelay(_ timebase: Int64) -> Int {
        return Int(swr_get_delay(cContext, timebase))
    }

    /// Convert audio.
    ///
    /// - Parameters:
    ///   - dst: output buffers, only the first one need be set in case of packed audio
    ///   - dstCount: amount of space available for output in samples per channel
    ///   - src: input buffers, only the first one need to be set in case of packed audio
    ///   - srcCount: number of input samples available in one channel
    /// - Returns: number of samples output per channel, negative value on error
    @discardableResult
    public func convert(
        dst: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        dstCount: Int,
        src: UnsafeMutablePointer<UnsafePointer<UInt8>?>,
        srcCount: Int
    ) -> Int {
        let ret = swr_convert(cContext, dst, Int32(dstCount), src, Int32(srcCount))
        return Int(ret)
    }

    deinit {
        var ptr: OpaquePointer? = cContext
        swr_free(&ptr)
    }
}

extension SwrContext: AVOptionAccessor {

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        return try body(UnsafeMutableRawPointer(cContext))
    }
}
