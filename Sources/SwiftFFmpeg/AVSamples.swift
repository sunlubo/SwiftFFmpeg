//
//  AVSample.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/6.
//

import CFFmpeg

public final class AVSamples {
    public let data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>
    public let size: Int
    public let linesize: Int
    public let channelCount: Int
    public let sampleCount: Int
    public let sampleFormat: AVSampleFormat

    /// Allocate a samples buffer for `sampleCount` samples, and fill data pointers and linesize accordingly.
    ///
    /// - Parameters:
    ///   - data: array to be filled with the pointer for each channel
    ///   - linesize: aligned size for audio buffer(s)
    ///   - channelCount: the number of channels
    ///   - sampleCount: the number of samples in a single channel
    ///   - sampleFormat: the sample format
    ///   - align: buffer size alignment (0 = default, 1 = no alignment)
    public init(
        channelCount: Int,
        sampleCount: Int,
        sampleFormat: AVSampleFormat,
        align: Int = 0
    ) {
        let data = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>.allocate(capacity: 4)
        data.initialize(to: nil)
        var linesize = 0 as Int32
        let ret = av_samples_alloc(data, &linesize, Int32(channelCount), Int32(sampleCount), sampleFormat, Int32(align))
        guard ret >= 0 else {
            fatalError("av_samples_alloc: \(AVError(code: ret))")
        }
        self.data = data
        self.size = Int(ret)
        self.linesize = Int(linesize)
        self.channelCount = channelCount
        self.sampleCount = sampleCount
        self.sampleFormat = sampleFormat
    }

    deinit {
        av_freep(data)
        data.deallocate()
    }

    /// Fill an audio buffer with silence.
    public func setSilence() {
        av_samples_set_silence(data, 0, Int32(sampleCount), Int32(channelCount), sampleFormat)
    }

    /// Get the required buffer size for the given audio parameters.
    ///
    /// - Parameters:
    ///   - channelCount: the number of channels
    ///   - sampleCount: the number of samples in a single channel
    ///   - sampleFormat: the sample format
    ///   - align: buffer size alignment (0 = default, 1 = no alignment)
    /// - Returns: required buffer size and calculated linesize
    /// - Throws: AVError
    public static func getBufferSize(
        channelCount: Int,
        sampleCount: Int,
        sampleFormat: AVSampleFormat,
        align: Int
    ) throws -> (Int, Int) {
        var linesize: Int32 = 0
        let ret = av_samples_get_buffer_size(
            &linesize,
            Int32(channelCount),
            Int32(sampleCount),
            sampleFormat,
            Int32(align)
        )
        try throwIfFail(ret)
        return (Int(ret), Int(linesize))
    }

    /// Fill plane data pointers and linesize for samples with sample format.
    ///
    /// The data array is filled with the pointers to the samples data planes:
    /// - for planar, set the start point of each channel's data within the buffer,
    /// - for packed, set the start point of the entire buffer only.
    ///
    /// The value pointed to by linesize is set to the aligned size of each channel's data buffer for
    /// planar layout, or to the aligned size of the buffer for all channels for packed layout.
    ///
    /// The buffer in buf must be big enough to contain all the samples (use `getBufferSize` to
    /// compute its minimum size), otherwise the data pointers will point to invalid data.
    ///
    /// - Parameters:
    ///   - data: array to be filled with the pointer for each channel
    ///   - buffer: the pointer to a buffer containing the samples
    ///   - channelCount: the number of channels
    ///   - sampleCount: the number of samples in a single channel
    ///   - sampleFormat: the sample format
    ///   - align: buffer size alignment (0 = default, 1 = no alignment)
    /// - Returns: the size in bytes required for the audio buffer, calculated linesize,
    /// - Throws: AVError
    public static func fillArrays(
        _ data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        buffer: UnsafeMutablePointer<UInt8>?,
        channelCount: Int,
        sampleCount: Int,
        sampleFormat: AVSampleFormat,
        align: Int = 0
    ) throws -> (Int, Int) {
        var linesize: Int32 = 0
        let ret = av_samples_fill_arrays(
            data,
            &linesize,
            buffer,
            Int32(channelCount),
            Int32(sampleCount),
            sampleFormat,
            Int32(align)
        )
        try throwIfFail(ret)
        return (Int(ret), Int(linesize))
    }
}
