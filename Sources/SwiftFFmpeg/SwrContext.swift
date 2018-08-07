//
//  SwrContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/6.
//

import CFFmpeg

public final class SwrContext {
    internal let ctx: OpaquePointer

    /// Allocate SwrContext.
    ///
    /// If you use this function you will need to set the parameters (manually or with swr_alloc_set_opts())
    /// before calling swr_init().
    public init() {
        ctx = swr_alloc()
    }

    /// Allocate SwrContext if needed and set/reset common parameters.
    ///
    /// - Parameters:
    ///   - srcChannelLayout: input channel layout
    ///   - srcSampleFmt: input sample format
    ///   - srcSampleRate: input sample rate (frequency in Hz)
    ///   - dstChannelLayout: output channel layout
    ///   - dstSampleFmt: output sample format
    ///   - dstSampleRate: output sample rate (frequency in Hz)
    public init(
        srcChannelLayout: AVChannelLayout,
        srcSampleFmt: AVSampleFormat,
        srcSampleRate: Int,
        dstChannelLayout: AVChannelLayout,
        dstSampleFmt: AVSampleFormat,
        dstSampleRate: Int
    ) {
        ctx = swr_alloc_set_opts(
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

    /// Check whether an swr context has been initialized or not.
    public var isInitialized: Bool {
        return swr_is_initialized(ctx) > 0
    }

    /// Initialize context after user parameters have been set.
    ///
    /// - Throws: AVError
    public func initialize() throws {
        try throwIfFail(swr_init(ctx))
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
        return Int(swr_get_delay(ctx, timebase))
    }

    /// Convert audio.
    ///
    /// - Parameters:
    ///   - src: input buffers, only the first one need to be set in case of packed audio
    ///   - srcCount: number of input samples available in one channel
    ///   - dst: output buffers, only the first one need be set in case of packed audio
    ///   - dstCount: amount of space available for output in samples per channel
    /// - Returns: number of samples output per channel, negative value on error
    public func convert(
        src: UnsafeMutablePointer<UnsafePointer<UInt8>?>,
        srcCount: Int,
        dst: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        dstCount: Int
    ) -> Int {
        let ret = swr_convert(ctx, dst, Int32(dstCount), src, Int32(srcCount))
        return Int(ret)
    }

    deinit {
        var ptr: OpaquePointer? = ctx
        swr_free(&ptr)
    }
}
