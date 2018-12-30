//
//  SwsContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/11.
//

import CFFmpeg

// MARK: - SwsContext

public final class SwsContext {
    public static let `class` = AVClass(cClassPtr: sws_get_class())

    let cContext: OpaquePointer

    /// Allocate an empty `SwsContext`.
    public init() {
        cContext = sws_alloc_context()
    }

    /// Allocate and return an `SwsContext`.
    ///
    /// - Parameters:
    ///   - srcWidth: the width of the source image
    ///   - srcHeight: the height of the source image
    ///   - srcPixelFormat: the source image format
    ///   - dstWidth: the width of the destination image
    ///   - dstHeight: the height of the destination image
    ///   - dstPixelFormat: the destination image format
    ///   - flags: specify which algorithm and options to use for rescaling
    public init?(
        srcWidth: Int, srcHeight: Int, srcPixelFormat: AVPixelFormat,
        dstWidth: Int, dstHeight: Int, dstPixelFormat: AVPixelFormat,
        flags: Flag
    ) {
        guard let ptr = sws_getContext(
            Int32(srcWidth), Int32(srcHeight), srcPixelFormat,
            Int32(dstWidth), Int32(dstHeight), dstPixelFormat,
            flags.rawValue,
            nil, nil,
            nil
        ) else {
            return nil
        }
        cContext = ptr
    }

    /// Scale the image slice in srcSlice and put the resulting scaled slice in the image in dst.
    ///
    /// A slice is a sequence of consecutive rows in an image.
    ///
    /// Slices have to be provided in sequential order, either in top-bottom or bottom-top order.
    /// If slices are provided in non-sequential order the behavior of the function is undefined.
    ///
    /// - Parameters:
    ///   - src: the array containing the pointers to the planes of the source slice
    ///   - srcStride: the array containing the strides for each plane of the source image
    ///   - srcSliceY: the position in the source image of the slice to process, that is the number
    ///     (counted starting from zero) in the image of the first row of the slice
    ///   - srcSliceHeight: the height of the source slice, that is the number of rows in the slice
    ///   - dst: the array containing the pointers to the planes of the destination image
    ///   - dstStride: the array containing the strides for each plane of the destination image
    /// - Returns: the height of the output slice
    @discardableResult
    public func scale(
        src: UnsafePointer<UnsafePointer<UInt8>?>,
        srcStride: UnsafePointer<Int32>,
        srcSliceY: Int,
        srcSliceHeight: Int,
        dst: UnsafePointer<UnsafeMutablePointer<UInt8>?>,
        dstStride: UnsafePointer<Int32>
    ) -> Int {
        return Int(sws_scale(cContext, src, srcStride, Int32(srcSliceY), Int32(srcSliceHeight), dst, dstStride))
    }

    /// Returns a Boolean value indicating whether the pixel format is a supported input format.
    ///
    /// - Parameter pixFmt: pixel format
    /// - Returns: true if it is supported; otherwise false.
    public static func isSupportedInput(_ pixFmt: AVPixelFormat) -> Bool {
        return sws_isSupportedInput(pixFmt) > 0
    }

    /// Returns a Boolean value indicating whether the pixel format is a supported output format.
    ///
    /// - Parameter pixFmt: pixel format
    /// - Returns: true if it is supported; otherwise false.
    public static func isSupportedOutput(_ pixFmt: AVPixelFormat) -> Bool {
        return sws_isSupportedOutput(pixFmt) > 0
    }

    /// Returns a Boolean value indicating whether an endianness conversion is supported.
    ///
    /// - Parameter pixFmt: pixel format
    /// - Returns: true if it is supported; otherwise false.
    public static func isSupportedEndiannessConversion(_ pixFmt: AVPixelFormat) -> Bool {
        return sws_isSupportedEndiannessConversion(pixFmt) > 0
    }

    deinit {
        sws_freeContext(cContext)
    }
}

extension SwsContext {

    public struct Flag: OptionSet {
        public static let fastBilinear = Flag(rawValue: SWS_FAST_BILINEAR)
        public static let bilinear = Flag(rawValue: SWS_BILINEAR)
        public static let bicubic = Flag(rawValue: SWS_BICUBIC)
        public static let x = Flag(rawValue: SWS_X)
        public static let point = Flag(rawValue: SWS_POINT)
        public static let area = Flag(rawValue: SWS_AREA)
        public static let bicublin = Flag(rawValue: SWS_BICUBLIN)
        public static let gauss = Flag(rawValue: SWS_GAUSS)
        public static let sinc = Flag(rawValue: SWS_SINC)
        public static let lanczos = Flag(rawValue: SWS_LANCZOS)
        public static let spLine = Flag(rawValue: SWS_SPLINE)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension SwsContext.Flag: CustomStringConvertible {

    public var description: String {
        var str = "["
        if contains(.fastBilinear) { str += "fastBilinear, " }
        if contains(.bilinear) { str += "bilinear, " }
        if contains(.bicubic) { str += "bicubic, " }
        if contains(.x) { str += "x, " }
        if contains(.point) { str += "point, " }
        if contains(.area) { str += "area, " }
        if contains(.bicublin) { str += "bicublin, " }
        if contains(.gauss) { str += "gauss, " }
        if contains(.sinc) { str += "sinc, " }
        if contains(.lanczos) { str += "lanczos, " }
        if contains(.spLine) { str += "spLine, " }
        if str.suffix(2) == ", " {
            str.removeLast(2)
        }
        str += "]"
        return str
    }
}

extension SwsContext: AVOptionAccessor {

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        return try body(UnsafeMutableRawPointer(cContext))
    }
}
