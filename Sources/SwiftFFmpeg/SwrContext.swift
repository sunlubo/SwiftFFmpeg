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
    ///   - outChannelLayout: output channel layout (AV_CH_LAYOUT_*)
    ///   - outSampleFmt: output sample format (AV_SAMPLE_FMT_*).
    ///   - outSampleRate: output sample rate (frequency in Hz)
    ///   - inChannelLayout: input channel layout (AV_CH_LAYOUT_*)
    ///   - inSampleFmt: input sample format (AV_SAMPLE_FMT_*).
    ///   - inSampleRate: input sample rate (frequency in Hz)
    public init(
        outChannelLayout: Int64,
        outSampleFmt: AVSampleFormat,
        outSampleRate: Int32,
        inChannelLayout: Int64,
        inSampleFmt: AVSampleFormat,
        inSampleRate: Int32
    ) {
        ctx = swr_alloc_set_opts(
            nil,
            outChannelLayout,
            outSampleFmt,
            outSampleRate,
            inChannelLayout,
            inSampleFmt,
            inSampleRate,
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
    /// - Parameter base: timebase in which the returned delay will be
    ///   - if it's set to 1 the returned delay is in seconds
    ///   - if it's set to 1000 the returned delay is in milliseconds
    ///   - if it's set to the input sample rate then the returned delay is in input samples
    ///   - if it's set to the output sample rate then the returned delay is in output samples
    ///   - if it's the least common multiple of in_sample_rate and
    ///     out_sample_rate then an exact rounding-free delay will be eturned
    /// - Returns: the delay in 1 / base units.
    public func getDelay(_ base: Int64) -> Int64 {
        return swr_get_delay(ctx, base)
    }

    /// Convert audio.
    ///
    /// - Parameters:
    ///   - out: output buffers, only the first one need be set in case of packed audio
    ///   - outCount: amount of space available for output in samples per channel
    ///   - input: input buffers, only the first one need to be set in case of packed audio
    ///   - inCount: number of input samples available in one channel
    /// - Returns: number of samples output per channel, negative value on error
    /// - Throws: AVError
    public func convert(
        out: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        outCount: Int32,
        input: UnsafeMutablePointer<UnsafePointer<UInt8>?>?,
        inCount: Int32
    ) throws -> Int {
        let ret = swr_convert(ctx, out, outCount, input, inCount)
        try throwIfFail(ret)
        return Int(ret)
    }

    deinit {
        let ptr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        ptr.initialize(to: ctx)
        swr_free(ptr)
        ptr.deallocate()
    }
}

extension SwrContext: AVOptionProtocol {

    public var objPtr: UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(ctx)
    }
}
