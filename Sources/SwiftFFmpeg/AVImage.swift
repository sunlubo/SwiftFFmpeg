//
//  AVImage.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/12.
//

import CFFmpeg

public final class AVImage {

    /// Allocate an image with size w and h and pixel format pix_fmt, and fill pointers and linesizes accordingly.
    ///
    /// - Parameters:
    ///   - buf: buf
    ///   - linesizes: linesizes
    ///   - width: width
    ///   - height: height
    ///   - pixFmt: pixFmt
    ///   - align: the value to use for buffer size alignment
    /// - Returns: the size in bytes required for the image buffer, a negative error code in case of failure
    public static func alloc(
        buf: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        linesizes: UnsafeMutablePointer<Int32>,
        width: Int,
        height: Int,
        pixFmt: AVPixelFormat,
        align: Int = 0
    ) -> Int32 {
        return av_image_alloc(buf, linesizes, Int32(width), Int32(height), pixFmt, Int32(align))
    }

    public static func free(_ ptr: UnsafeMutableRawPointer) {
        av_freep(ptr)
    }
}
