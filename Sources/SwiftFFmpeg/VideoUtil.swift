//
//  VideoUtil.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/2.
//

import CFFmpeg

// MARK: - AVPixelFormat

public typealias AVPixelFormat = CFFmpeg.AVPixelFormat

/// Pixel format.
extension AVPixelFormat: CustomStringConvertible {
    public static let NONE = AV_PIX_FMT_NONE
    /// planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
    public static let YUV420P = AV_PIX_FMT_YUV420P
    /// packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
    public static let YUYV422 = AV_PIX_FMT_YUYV422
    /// packed RGB 8:8:8, 24bpp, RGBRGB...
    public static let RGB24 = AV_PIX_FMT_RGB24
    /// packed RGB 8:8:8, 24bpp, BGRBGR...
    public static let BGR24 = AV_PIX_FMT_BGR24
    /// planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    public static let YUV422P = AV_PIX_FMT_YUV422P
    /// planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
    public static let YUV444P = AV_PIX_FMT_YUV444P
    /// planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
    public static let YUV410P = AV_PIX_FMT_YUV410P
    /// planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
    public static let YUV411P = AV_PIX_FMT_YUV411P
    ///        Y        ,  8bpp
    public static let GRAY8 = AV_PIX_FMT_GRAY8
    ///        Y        ,  1bpp, 0 is white, 1 is black, in each byte pixels are ordered from the msb to the lsb
    public static let MONOWHITE = AV_PIX_FMT_MONOWHITE
    /// Y        ,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
    public static let MONOBLACK = AV_PIX_FMT_MONOBLACK
    /// 8 bits with AV_PIX_FMT_RGB32 palette
    public static let PAL8 = AV_PIX_FMT_PAL8
    /// planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV420P and setting color_range
    @available(*, deprecated, message: "Use AV_PIX_FMT_YUV420P and setting color_range.")
    public static let YUVJ420P = AV_PIX_FMT_YUVJ420P
    /// planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV422P and setting color_range
    @available(*, deprecated, message: "Use AV_PIX_FMT_YUV422P and setting color_range.")
    public static let YUVJ422P = AV_PIX_FMT_YUVJ422P
    /// planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV444P and setting color_range
    @available(*, deprecated, message: "Use AV_PIX_FMT_YUV444P and setting color_range.")
    public static let YUVJ444P = AV_PIX_FMT_YUVJ444P
    /// packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
    public static let UYVY422 = AV_PIX_FMT_UYVY422
    /// packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
    public static let UYYVYY411 = AV_PIX_FMT_UYYVYY411
    /// packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
    public static let BGR8 = AV_PIX_FMT_BGR8
    /// packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte
    /// is the one composed by the 4 msb bits
    public static let BGR4 = AV_PIX_FMT_BGR4
    /// packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
    public static let BGR4_BYTE = AV_PIX_FMT_BGR4_BYTE
    /// packed RGB 3:3:2,  8bpp, (msb)2R 3G 3B(lsb)
    public static let RGB8 = AV_PIX_FMT_RGB8
    /// packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte
    /// is the one composed by the 4 msb bits
    public static let RGB4 = AV_PIX_FMT_RGB4
    /// packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
    public static let RGB4_BYTE = AV_PIX_FMT_RGB4_BYTE
    /// planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved
    /// (first byte U and the following byte V)
    public static let NV12 = AV_PIX_FMT_NV12
    /// as above, but U and V bytes are swapped
    public static let NV21 = AV_PIX_FMT_NV21

    /// packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
    public static let ARGB = AV_PIX_FMT_ARGB
    /// packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
    public static let RGBA = AV_PIX_FMT_RGBA
    /// packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
    public static let ABGR = AV_PIX_FMT_ABGR
    /// packed BGRA 8:8:8:8, 32bpp, BGRABGRA...
    public static let BGRA = AV_PIX_FMT_BGRA

    ///        Y        , 16bpp, big-endian
    public static let GRAY16BE = AV_PIX_FMT_GRAY16BE
    ///        Y        , 16bpp, little-endian
    public static let GRAY16LE = AV_PIX_FMT_GRAY16LE
    /// planar YUV 4:4:0 (1 Cr & Cb sample per 1x2 Y samples)
    public static let YUV440P = AV_PIX_FMT_YUV440P
    /// planar YUV 4:4:0 full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV440P and setting color_range
    public static let YUVJ440P = AV_PIX_FMT_YUVJ440P
    /// planar YUV 4:2:0, 20bpp, (1 Cr & Cb sample per 2x2 Y & A samples)
    public static let YUVA420P = AV_PIX_FMT_YUVA420P
    /// packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as big-endian
    public static let RGB48BE = AV_PIX_FMT_RGB48BE
    /// packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as little-endian
    public static let RGB48LE = AV_PIX_FMT_RGB48LE

    /// packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), big-endian
    public static let RGB565BE = AV_PIX_FMT_RGB565BE
    /// packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), little-endian
    public static let RGB565LE = AV_PIX_FMT_RGB565LE
    /// packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), big-endian   , X=unused/undefined
    public static let RGB555BE = AV_PIX_FMT_RGB555BE
    /// packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), little-endian, X=unused/undefined
    public static let RGB555LE = AV_PIX_FMT_RGB555LE

    /// packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), big-endian
    public static let BGR565BE = AV_PIX_FMT_BGR565BE
    /// packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), little-endian
    public static let BGR565LE = AV_PIX_FMT_BGR565LE
    /// packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), big-endian   , X=unused/undefined
    public static let BGR555BE = AV_PIX_FMT_BGR555BE
    /// packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), little-endian, X=unused/undefined
    public static let BGR555LE = AV_PIX_FMT_BGR555LE

    public var name: String {
        if let strBytes = av_get_pix_fmt_name(self) {
            return String(cString: strBytes)
        }
        return "unknown"
    }

    public var description: String {
        return name
    }
}
