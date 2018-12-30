//
//  AVSample.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/6.
//

import CFFmpeg

public final class AVSample {

    /// Fill plane data pointers and linesize for samples with sample format.
    ///
    /// The data array is filled with the pointers to the samples data planes:
    /// for planar, set the start point of each channel's data within the buffer,
    /// for packed, set the start point of the entire buffer only.
    ///
    /// The value pointed to by linesize is set to the aligned size of each channel's data buffer for
    /// planar layout, or to the aligned size of the buffer for all channels for packed layout.
    ///
    /// The buffer in buf must be big enough to contain all the samples (use `AVSample.getBufferSize` to
    /// compute its minimum size), otherwise the data pointers will point to invalid data.
    ///
    /// - Parameters:
    ///   - data: array to be filled with the pointer for each channel
    ///   - linesize: calculated linesize
    ///   - ptr: the pointer to a buffer containing the samples
    ///   - channelCount: the number of channels
    ///   - sampleCount: the number of samples in a single channel
    ///   - sampleFormat: the sample format
    ///   - align: buffer size alignment (0 = default, 1 = no alignment)
    /// - Returns:  the size in bytes required for the audio buffer, a negative error code in case of failure
    @discardableResult
    public static func fillArrays(
        _ data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        linesize: UnsafeMutablePointer<Int32>? = nil,
        ptr: UnsafeMutablePointer<UInt8>?,
        channelCount: Int,
        sampleCount: Int,
        sampleFormat: AVSampleFormat,
        align: Int
    ) -> Int {
        let ret = av_samples_fill_arrays(
            data,
            linesize,
            ptr,
            Int32(channelCount),
            Int32(sampleCount),
            sampleFormat,
            Int32(align)
        )
        return Int(ret)
    }

    /// Allocate a samples buffer for nb_samples samples, and fill data pointers and linesize accordingly.
    ///
    /// - Parameters:
    ///   - data: array to be filled with the pointer for each channel
    ///   - linesize: aligned size for audio buffer(s)
    ///   - channelCount: the number of channels
    ///   - sampleCount: the number of samples in a single channel
    ///   - sampleFormat: the sample format
    ///   - align: buffer size alignment (0 = default, 1 = no alignment)
    /// - Returns: the size in bytes required for the audio buffer, a negative error code in case of failure
    @discardableResult
    public static func alloc(
        data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        linesize: UnsafeMutablePointer<Int32>,
        channelCount: Int,
        sampleCount: Int,
        sampleFormat: AVSampleFormat,
        align: Int
    ) -> Int {
        let ret = av_samples_alloc(data, linesize, Int32(channelCount), Int32(sampleCount), sampleFormat, Int32(align))
        return Int(ret)
    }

    /// Allocate a data pointers array, samples buffer for nb_samples samples, and fill data pointers and linesize
    /// accordingly.
    ///
    /// This is the same as `AVSample.alloc`, but also allocates the data pointers array.
    ///
    /// - Parameters:
    ///   - data: array to be filled with the pointer for each channel
    ///   - linesize: aligned size for audio buffer(s)
    ///   - channelCount: the number of channels
    ///   - sampleCount: the number of samples in a single channel
    ///   - sampleFormat: the sample format
    ///   - align: buffer size alignment (0 = default, 1 = no alignment)
    /// - Returns: the size in bytes required for the audio buffer, a negative error code in case of failure
    @discardableResult
    public static func alloc2(
        data: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?>,
        linesize: UnsafeMutablePointer<Int32>,
        channelCount: Int,
        sampleCount: Int,
        sampleFormat: AVSampleFormat,
        align: Int
    ) -> Int {
        let ret = av_samples_alloc_array_and_samples(
            data,
            linesize,
            Int32(channelCount),
            Int32(sampleCount),
            sampleFormat,
            Int32(align)
        )
        return Int(ret)
    }

    public static func free(_ ptr: UnsafeMutableRawPointer) {
        av_freep(ptr)
    }

    /// Get the required buffer size for the given audio parameters.
    ///
    /// - Parameters:
    ///   - linesize: calculated linesize
    ///   - channelCount: the number of channels
    ///   - sampleCount: the number of samples in a single channel
    ///   - sampleFormat: the sample format
    ///   - align: buffer size alignment (0 = default, 1 = no alignment)
    /// - Returns: required buffer size, or negative error code on failure
    public static func getBufferSize(
        linesize: UnsafeMutablePointer<Int32>? = nil,
        channelCount: Int,
        sampleCount: Int,
        sampleFormat: AVSampleFormat,
        align: Int
    ) -> Int {
        let ret = av_samples_get_buffer_size(linesize, Int32(channelCount), Int32(sampleCount), sampleFormat, Int32(align))
        return Int(ret)
    }
}
