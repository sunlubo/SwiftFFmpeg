//
//  AVImage.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/12.
//

import CFFmpeg

public final class AVImage {
    public let data: UnsafeMutableBufferPointer<UnsafeMutablePointer<UInt8>?>
    public let size: Int
    public let linesizes: UnsafeMutableBufferPointer<Int32>
    public let width: Int
    public let height: Int
    public let pixelFormat: AVPixelFormat

    private var freeWhenDone = false

    /// Allocate an image with size and pixel format.
    ///
    /// - Parameters:
    ///   - width: image width
    ///   - height: image height
    ///   - pixelFormat: image pixel format
    ///   - align: the value to use for buffer size alignment, e.g. 1(no alignment), 16, 32, 64
    public init(width: Int, height: Int, pixelFormat: AVPixelFormat, align: Int = 1) {
        let data = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>.allocate(capacity: 4)
        data.initialize(to: nil)

        let linesizes = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
        linesizes.initialize(to: 0)

        let ret = av_image_alloc(data, linesizes, Int32(width), Int32(height), pixelFormat, Int32(align))
        guard ret >= 0 else {
            fatalError("av_image_alloc: \(AVError(code: ret))")
        }

        self.data = UnsafeMutableBufferPointer(start: data, count: 4)
        self.size = Int(ret)
        self.linesizes = UnsafeMutableBufferPointer(start: linesizes, count: 4)
        self.width = width
        self.height = height
        self.pixelFormat = pixelFormat
        self.freeWhenDone = true
    }

    /// Create an image from the given frame.
    public init(frame: AVFrame) {
        precondition(frame.pixelFormat != .NONE)

        let data = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>.allocate(capacity: 4)
        data.initialize(to: nil)
        data.assign(from: frame.data.baseAddress!, count: 4)

        let linesizes = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
        linesizes.initialize(to: 0)
        linesizes.assign(from: frame.linesize.baseAddress!, count: 4)

        self.data = UnsafeMutableBufferPointer(start: data, count: 4)
        self.size = frame.buffer.reduce(0) { $0 + ($1?.size ?? 0) }
        self.linesizes = UnsafeMutableBufferPointer(start: linesizes, count: 4)
        self.width = frame.width
        self.height = frame.height
        self.pixelFormat = frame.pixelFormat
        self.freeWhenDone = false
    }

    deinit {
        if freeWhenDone {
            av_freep(data.baseAddress)
        }
        data.deallocate()
        linesizes.deallocate()
    }

    /// Reformat image using the given `SwsContext`.
    ///
    /// - Throws: AVError
    public func reformat(context: SwsContext) throws -> AVImage {
        let dstWidth = try context.integer(forKey: "dstw") as Int
        let dstHeight = try context.integer(forKey: "dsth") as Int
        let dstFormat = try context.pixelFormat(forKey: "dst_format")
        let image = AVImage(width: dstWidth, height: dstHeight, pixelFormat: dstFormat)
        var srcLinesizes = linesizes.map({ Int32($0) })
        var dstLinesizes = linesizes.map({ Int32($0) })
        data.withMemoryRebound(to: UnsafePointer<UInt8>?.self) { bufPtr -> Void in
            context.scale(
                src: bufPtr.baseAddress!,
                srcStride: &srcLinesizes,
                srcSliceY: 0,
                srcSliceHeight: height,
                dst: image.data.baseAddress!,
                dstStride: &dstLinesizes
            )
        }
        return image
    }

    /// Compute the size of an image line with format and width for the plane.
    ///
    /// - Returns: the computed size in bytes
    /// - Throws: AVError
    public static func getLinesize(pixelFormat: AVPixelFormat, width: Int, plane: Int) throws -> Int {
        let ret = av_image_get_linesize(pixelFormat, Int32(width), Int32(plane))
        try throwIfFail(ret)
        return Int(ret)
    }

    /// Fill plane linesizes for an image with pixel format and width.
    ///
    /// - Throws: AVError
    public static func fillLinesizes(
        _ linesizes: UnsafeMutablePointer<Int32>,
        pixelFormat: AVPixelFormat,
        width: Int
    ) throws {
        try throwIfFail(av_image_fill_linesizes(linesizes, pixelFormat, Int32(width)))
    }

    /// Fill plane data pointers for an image with pixel format and height.
    ///
    /// - Parameters:
    ///   - data: pointers array to be filled with the pointer for each image plane
    ///   - pixelFormat: the pixel format of the image
    ///   - height: the height of the image
    ///   - buffer: the pointer to a buffer which will contain the image
    ///   - linesizes: the array containing the linesize for each plane, should be filled by `fillLinesizes`
    /// - Returns: the size in bytes required for the image buffer
    /// - Throws: AVError
    @discardableResult
    public static func fillPointers(
        _ data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        pixelFormat: AVPixelFormat,
        height: Int,
        buffer: UnsafeMutablePointer<UInt8>?,
        linesizes: UnsafePointer<Int32>?
    ) throws -> Int {
        let ret = av_image_fill_pointers(data, pixelFormat, Int32(height), buffer, linesizes)
        try throwIfFail(ret)
        return Int(ret)
    }

    /// Return the size in bytes of the amount of data required to store an image with the given parameters.
    ///
    /// - Parameters:
    ///   - pixelFormat: the pixel format of the image
    ///   - width: the width of the image in pixels
    ///   - height: the height of the image in pixels
    ///   - align: the assumed linesize alignment
    /// - Returns: the buffer size in bytes
    /// - Throws: AVError
    public static func getBufferSize(
        pixelFormat: AVPixelFormat,
        width: Int,
        height: Int,
        align: Int
    ) throws -> Int {
        let ret = av_image_get_buffer_size(pixelFormat, Int32(width), Int32(height), Int32(align))
        try throwIfFail(ret)
        return Int(ret)
    }
}
