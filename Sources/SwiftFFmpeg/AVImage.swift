//
//  AVImage.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/12.
//

import CFFmpeg

public final class AVImage {

    /// Compute the size of an image line with format and width for the plane.
    ///
    /// - Returns: the computed size in bytes
    public static func getLinesize(pixFmt: AVPixelFormat, width: Int, plane: Int) -> Int {
        return Int(av_image_get_linesize(pixFmt, Int32(width), Int32(plane)))
    }

    /// Fill plane linesizes for an image with pixel format and width.
    ///
    /// - Returns: true in case of success, false otherwise
    @discardableResult
    public static func fillLinesizes(
        _ linesizes: UnsafeMutablePointer<Int32>,
        pixFmt: AVPixelFormat,
        width: Int
    ) -> Bool {
        return av_image_fill_linesizes(linesizes, pixFmt, Int32(width)) >= 0
    }

    /// Fill plane data pointers for an image with pixel format pix_fmt and height height.
    ///
    /// - Parameters:
    ///   - data: pointers array to be filled with the pointer for each image plane
    ///   - ptr: the pointer to a buffer which will contain the image
    ///   - linesizes: the array containing the linesize for each plane, should be filled by `fillLinesizes`
    /// - Returns: the size in bytes required for the image buffer, a negative error code in case of failure
    @discardableResult
    public static func fillPointers(
        _ data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        pixFmt: AVPixelFormat,
        height: Int,
        ptr: UnsafeMutablePointer<UInt8>?,
        linesizes: UnsafePointer<Int32>
    ) -> Int {
        return Int(av_image_fill_pointers(data, pixFmt, Int32(height), ptr, linesizes))
    }

    /// Allocate an image with size w and h and pixel format pix_fmt, and fill pointers and linesizes accordingly.
    ///
    /// - Returns: the size in bytes required for the image buffer, a negative error code in case of failure
    @discardableResult
    public static func alloc(
        data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        linesizes: UnsafeMutablePointer<Int32>,
        width: Int,
        height: Int,
        pixFmt: AVPixelFormat,
        align: Int
    ) -> Int {
        let ret = av_image_alloc(data, linesizes, Int32(width), Int32(height), pixFmt, Int32(align))
        return Int(ret)
    }

    public static func free(_ ptr: UnsafeMutableRawPointer) {
        av_freep(ptr)
    }

    /// Copy image in src to dst.
    public static func copy(
        src: UnsafeMutablePointer<UnsafePointer<UInt8>?>,
        srcLinesizes: UnsafePointer<Int32>,
        dst: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        dstLinesizes: UnsafeMutablePointer<Int32>,
        pixFmt: AVPixelFormat,
        width: Int,
        height: Int
    ) {
        av_image_copy(dst, dstLinesizes, src, srcLinesizes, pixFmt, Int32(width), Int32(height))
    }

    /// Return the size in bytes of the amount of data required to store an image with the given parameters.
    ///
    /// - Parameters:
    ///   - pixFmt: the pixel format of the image
    ///   - width: the width of the image in pixels
    ///   - height: the height of the image in pixels
    ///   - align: the assumed linesize alignment
    /// - Returns: the buffer size in bytes, a negative error code in case of failure
    public static func getBufferSize(pixFmt: AVPixelFormat, width: Int, height: Int, align: Int) -> Int {
        return Int(av_image_get_buffer_size(pixFmt, Int32(width), Int32(height), Int32(align)))
    }
}
