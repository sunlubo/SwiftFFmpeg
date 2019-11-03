//
//  VideoUtil.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/2.
//

import CFFmpeg

// MARK: - AVPictureType

public typealias AVPictureType = CFFmpeg.AVPictureType

extension AVPictureType {
    /// Undefined
    public static let none = AV_PICTURE_TYPE_NONE
    /// Intra
    public static let I = AV_PICTURE_TYPE_I
    /// Predicted
    public static let P = AV_PICTURE_TYPE_P
    /// Bi-dir predicted
    public static let B = AV_PICTURE_TYPE_B
    /// S(GMC)-VOP MPEG-4
    public static let S = AV_PICTURE_TYPE_S
    /// Switching Intra
    public static let SI = AV_PICTURE_TYPE_SI
    /// Switching Predicted
    public static let SP = AV_PICTURE_TYPE_SP
    /// BI type
    public static let BI = AV_PICTURE_TYPE_BI
}

extension AVPictureType: CustomStringConvertible {

    public var description: String {
        let char = av_get_picture_type_char(self)
        let scalar = Unicode.Scalar(Int(char))!
        return String(Character(scalar))
    }
}

// MARK: - AVPixelFormat

public typealias AVPixelFormat = CFFmpeg.AVPixelFormat

extension AVPixelFormat {
    public static let none = AV_PIX_FMT_NONE
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

    /// planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    public static let YUV420P16LE = AV_PIX_FMT_YUV420P16LE /// <
    /// planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    public static let YUV420P16BE = AV_PIX_FMT_YUV420P16BE ///
    /// planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let YUV422P16LE = AV_PIX_FMT_YUV422P16LE ///
    /// planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let YUV422P16BE = AV_PIX_FMT_YUV422P16BE ///
    /// planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let YUV444P16LE = AV_PIX_FMT_YUV444P16LE ///
    /// planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let YUV444P16BE = AV_PIX_FMT_YUV444P16BE
    /// HW decoding through DXVA2, Picture.data[3] contains a LPDIRECT3DSURFACE9 pointer
    public static let DXVA2_VLD = AV_PIX_FMT_DXVA2_VLD

    /// packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), little-endian, X=unused/undefined
    public static let RGB444LE = AV_PIX_FMT_RGB444LE
    /// packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), big-endian,    X=unused/undefined
    public static let RGB444BE = AV_PIX_FMT_RGB444BE
    /// packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), little-endian, X=unused/undefined
    public static let BGR444LE = AV_PIX_FMT_BGR444LE
    /// packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), big-endian,    X=unused/undefined
    public static let BGR444BE = AV_PIX_FMT_BGR444BE
    /// 8 bits gray, 8 bits alpha
    public static let YA8 = AV_PIX_FMT_YA8

    /// alias for AV_PIX_FMT_YA8
    public static let Y400A = AV_PIX_FMT_Y400A
    /// alias for AV_PIX_FMT_YA8
    public static let GRAY8A = AV_PIX_FMT_GRAY8A

    /// packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as big-endian
    public static let BGR48BE = AV_PIX_FMT_BGR48BE
    /// packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as little-endian
    public static let BGR48LE = AV_PIX_FMT_BGR48LE

    /// hardware decoding through VideoToolbox
    public static let videoToolbox = AV_PIX_FMT_VIDEOTOOLBOX

    /// number of pixel formats, __DO NOT USE THIS__ if you want to link with shared `libav*`
    /// because the number of formats might differ between versions
    public static let nb = AV_PIX_FMT_NB

    /// Return the pixel format corresponding to name.
    ///
    /// If there is no pixel format with name name, then looks for a pixel format with the name
    /// corresponding to the native endian format of name.
    /// For example in a little-endian system, first looks for "gray16", then for "gray16le".
    ///
    /// Finally if no pixel format has been found, returns `nil`.
    public init?(name: String) {
        let type = av_get_pix_fmt(name)
        if type == .none { return nil }
        self = type
    }

    // The name of the pixel format.
    public var name: String {
        String(cString: av_get_pix_fmt_name(self)) ?? "unknown"
    }

    /// The number of planes in the pixel format.
    public var planeCount: Int {
        let count = Int(av_pix_fmt_count_planes(self))
        return count >= 0 ? count : 0
    }

    /// The pixel format descriptor of the pixel format.
    public var descriptor: AVPixelFormatDescriptor? {
        if let desc = av_pix_fmt_desc_get(self) {
            return AVPixelFormatDescriptor(cDescriptorPtr: desc)
        } else {
            return nil
        }
    }
}

public typealias AVComponentDescriptor = CFFmpeg.AVComponentDescriptor

public struct AVPixelFormatDescriptor {
    let cDescriptorPtr: UnsafePointer<AVPixFmtDescriptor>
    var cDescriptor: AVPixFmtDescriptor { return cDescriptorPtr.pointee }

    init(cDescriptorPtr: UnsafePointer<AVPixFmtDescriptor>) {
        self.cDescriptorPtr = cDescriptorPtr
    }

    /// The name of the pixel format descriptor.
    public var name: String {
        String(cString: cDescriptor.name) ?? "unknown"
    }

    /// The number of components each pixel has, (1-4)
    public var numberOfComponents: Int {
        Int(cDescriptor.nb_components)
    }

    /// Amount to shift the luma width right to find the chroma width.
    /// For YV12 this is 1 for example.
    /// chroma_width = AV_CEIL_RSHIFT(luma_width, log2_chroma_w)
    /// The note above is needed to ensure rounding up.
    /// This value only refers to the chroma components.
    public var log2ChromaW: Int {
        Int(cDescriptor.log2_chroma_w)
    }

    /// Amount to shift the luma height right to find the chroma height.
    /// For YV12 this is 1 for example.
    /// chroma_height= AV_CEIL_RSHIFT(luma_height, log2_chroma_h)
    /// The note above is needed to ensure rounding up.
    /// This value only refers to the chroma components.
    public var log2ChromaH: Int {
        Int(cDescriptor.log2_chroma_h)
    }

    /// Parameters that describe how pixels are packed.
    /// If the format has 1 or 2 components, then luma is 0.
    /// If the format has 3 or 4 components:
    ///   if the RGB flag is set then 0 is red, 1 is green and 2 is blue;
    ///   otherwise 0 is luma, 1 is chroma-U and 2 is chroma-V.
    ///
    /// If present, the Alpha channel is always the last component.
    public var componentDescriptors: [SwiftFFmpeg.AVComponentDescriptor] {
        [cDescriptor.comp.0, cDescriptor.comp.1, cDescriptor.comp.2, cDescriptor.comp.3]
    }

    /// A wrapper around the C property for flags, containing AV_PIX_FMT_FLAG constants in a option set.
    public var flags: AVPixelFormatFlags {
        AVPixelFormatFlags(rawValue: cDescriptor.flags)
    }

    /// Alternative comma-separated names.
    public var alias: String? {
        String(cString: cDescriptor.alias)
    }

    /// Return the number of bits per pixel used by the pixel format
    /// described by pixdesc. Note that this is not the same as the number
    /// of bits per sample.
    /// The returned number of bits refers to the number of bits actually
    /// used for storing the pixel information, that is padding bits are
    /// not counted.
    public var bitsPerPixel: Int {
        Int(av_get_bits_per_pixel(cDescriptorPtr))
    }

    /// Return the number of bits per pixel for the pixel format described by pixdesc, including any padding or unused bits.
    public var bitsPerPixelPadded: Int {
        Int(av_get_padded_bits_per_pixel(cDescriptorPtr))
    }

    /// @return an AVPixelFormat id described by desc, or AV_PIX_FMT_NONE if desc
    /// is not a valid pointer to a pixel format descriptor.
    public var id: AVPixelFormat {
        av_pix_fmt_desc_get_id(cDescriptorPtr)
    }
}

public struct AVPixelFormatFlags: OptionSet {
    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    /// Pixel format is big-endian.
    public static let BE = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_BE))

    /// Pixel format has a palette in data[1], values are indexes in this palette.
    public static let PAL = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_PAL))

    /// All values of a component are bit-wise packed end to end.
    public static let BITSTREAM = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_BITSTREAM))

    /// Pixel format is an HW accelerated format.
    public static let HWACCEL = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_HWACCEL))

    /// At least one pixel component is not in the first data plane.
    public static let PLANAR = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_PLANAR))

    /// The pixel format contains RGB-like data (as opposed to YUV/grayscale).
    public static let RGB = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_RGB))

    /// The pixel format is "pseudo-paletted". This means that it contains a
    /// fixed palette in the 2nd plane but the palette is fixed/constant for each
    /// PIX_FMT. This allows interpreting the data as if it was PAL8, which can
    /// in some cases be simpler. Or the data can be interpreted purely based on
    /// the pixel format without using the palette.
    /// An example of a pseudo-paletted format is AV_PIX_FMT_GRAY8
    /// @deprecated This flag is deprecated, and will be removed. When it is removed,
    /// the extra palette allocation in AVFrame.data[1] is removed as well. Only
    /// actual paletted formats (as indicated by AV_PIX_FMT_FLAG_PAL) will have a
    /// palette. Starting with FFmpeg versions which have this flag deprecated, the
    /// extra "pseudo" palette is already ignored, and API users are not required to
    /// allocate a palette for AV_PIX_FMT_FLAG_PSEUDOPAL formats (it was required
    /// before the deprecation, though).
    public static let PSEUDOPAL = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_PSEUDOPAL))

    /// The pixel format has an alpha channel. This is set on all formats that
    /// support alpha in some way, including AV_PIX_FMT_PAL8. The alpha is always
    /// straight, never pre-multiplied.
    /// If a codec or a filter does not support alpha, it should set all alpha to
    /// opaque, or use the equivalent pixel formats without alpha component, e.g.
    /// AV_PIX_FMT_RGB0 (or AV_PIX_FMT_RGB24 etc.) instead of AV_PIX_FMT_RGBA.
    public static let ALPHA = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_ALPHA))

    /// The pixel format is following a Bayer pattern
    public static let BAYER = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_BAYER))

    /// The pixel format contains IEEE-754 floating point values. Precision (double,
    /// single, or half) should be determined by the pixel size (64, 32, or 16 bits).
    public static let FLOAT = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_FLOAT))
}

extension AVPixelFormat: CustomStringConvertible {

    public var description: String {
        name
    }
}

public typealias AVColorRange = CFFmpeg.AVColorRange

extension CFFmpeg.AVColorRange {
    public static let UNSPECIFIED = AVCOL_RANGE_UNSPECIFIED

    /// the normal 219*2^(n-8) "MPEG" YUV ranges
    public static let MPEG = AVCOL_RANGE_MPEG

    /// the normal     2^n-1   "JPEG" YUV ranges
    public static let JPEG = AVCOL_RANGE_JPEG

    /// Not part of ABI
    public static let NB = AVCOL_RANGE_NB

    /// Return the color range corresponding to name.
    ///
    /// If there is no color range with name name, an error is thrown..
    public init?(name: String) throws {
        let range = av_color_range_from_name(name)

        if range < 0 {
            throw AVError(code: range)
        }

        self.init(UInt32(range))
    }

    // The name of the color range.
    public var name: String {
        String(cString: av_color_range_name(self)) ?? "unknown"
    }
}

public typealias AVColorPrimaries = CFFmpeg.AVColorPrimaries

extension CFFmpeg.AVColorPrimaries {
    public static let RESERVED0 = AVCOL_PRI_RESERVED0
    /// also ITU-R BT1361 / IEC 61966-2-4 / SMPTE RP177 Annex B
    public static let BT709 = AVCOL_PRI_BT709
    public static let UNSPECIFIED = AVCOL_PRI_UNSPECIFIED
    public static let RESERVED = AVCOL_PRI_RESERVED
    /// also FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
    public static let BT470M = AVCOL_PRI_BT470M
    /// also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM
    public static let BT470BG = AVCOL_PRI_BT470BG
    /// also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
    public static let SMPTE170M = AVCOL_PRI_SMPTE170M
    /// functionally identical to above
    public static let SMPTE240M = AVCOL_PRI_SMPTE240M
    /// colour filters using Illuminant C
    public static let FILM = AVCOL_PRI_FILM
    /// ITU-R BT2020
    public static let BT2020 = AVCOL_PRI_BT2020
    /// SMPTE ST 428-1 (CIE 1931 XYZ)
    public static let SMPTE428 = AVCOL_PRI_SMPTE428
    public static let SMPTEST428_1 = AVCOL_PRI_SMPTEST428_1
    /// SMPTE ST 431-2 (2011) / DCI P3
    public static let SMPTE431 = AVCOL_PRI_SMPTE431
    /// SMPTE ST 432-1 (2010) / P3 D65 / Display P3
    public static let SMPTE432 = AVCOL_PRI_SMPTE432
    /// JEDEC P22 phosphors
    public static let JEDEC_P22 = AVCOL_PRI_JEDEC_P22
    /// Not part of ABI
    public static let NB = AVCOL_PRI_NB

    /// Return the color primaries corresponding to name.
    ///
    /// If there is no color primaries with name name, an error is thrown.
    public init?(name: String) throws {
        let range = av_color_primaries_from_name(name)

        if range < 0 {
            throw AVError(code: range)
        }

        self.init(UInt32(range))
    }

    // The name of the color primaries.
    public var name: String {
        String(cString: av_color_primaries_name(self)) ?? "unknown"
    }
}

public typealias AVColorTransferCharacteristic = CFFmpeg.AVColorTransferCharacteristic

extension CFFmpeg.AVColorTransferCharacteristic {
    public static let RESERVED0 = AVCOL_TRC_RESERVED0
    /// also ITU-R BT1361
    public static let BT709 = AVCOL_TRC_BT709
    public static let UNSPECIFIED = AVCOL_TRC_UNSPECIFIED
    public static let RESERVED = AVCOL_TRC_RESERVED
    /// also ITU-R BT470M / ITU-R BT1700 625 PAL & SECAM
    public static let GAMMA22 = AVCOL_TRC_GAMMA22
    /// also ITU-R BT470BG
    public static let GAMMA28 = AVCOL_TRC_GAMMA28
    /// also ITU-R BT601-6 525 or 625 / ITU-R BT1358 525 or 625 / ITU-R BT1700 NTSC
    public static let SMPTE170M = AVCOL_TRC_SMPTE170M
    public static let SMPTE240M = AVCOL_TRC_SMPTE240M
    /// "Linear transfer characteristics"
    public static let LINEAR = AVCOL_TRC_LINEAR
    /// "Logarithmic transfer characteristic (100:1 range)"
    public static let LOG = AVCOL_TRC_LOG
    /// "Logarithmic transfer characteristic (100 * Sqrt(10) : 1 range)"
    public static let LOG_SQRT = AVCOL_TRC_LOG_SQRT
    /// IEC 61966-2-4
    public static let IEC61966_2_4 = AVCOL_TRC_IEC61966_2_4
    /// ITU-R BT1361 Extended Colour Gamut
    public static let BT1361_ECG = AVCOL_TRC_BT1361_ECG
    /// IEC 61966-2-1 (sRGB or sYCC)
    public static let IEC61966_2_1 = AVCOL_TRC_IEC61966_2_1
    /// ITU-R BT2020 for 10-bit system
    public static let BT2020_10 = AVCOL_TRC_BT2020_10
    /// ITU-R BT2020 for 12-bit system
    public static let BT2020_12 = AVCOL_TRC_BT2020_12
    /// SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems
    public static let SMPTE2084 = AVCOL_TRC_SMPTE2084
    public static let SMPTEST2084 = AVCOL_TRC_SMPTEST2084
    /// SMPTE ST 428-1
    public static let SMPTE428 = AVCOL_TRC_SMPTE428
    public static let SMPTEST428_1 = AVCOL_TRC_SMPTEST428_1
    /// ARIB STD-B67, known as "Hybrid log-gamma"
    public static let ARIB_STD_B67 = AVCOL_TRC_ARIB_STD_B67
    /// Not part of ABI
    public static let NB = AVCOL_TRC_NB

    /// Return the color transfer characteristic corresponding to name.
    ///
    /// If there is no color transfer characteristic with name name, an error is thrown.
    public init?(name: String) throws {
        let range = av_color_transfer_from_name(name)

        if range < 0 {
            throw AVError(code: range)
        }

        self.init(UInt32(range))
    }

    // The name of the color transfer characteristic.
    public var name: String {
        String(cString: av_color_transfer_name(self)) ?? "unknown"
    }
}

public typealias AVColorSpace = CFFmpeg.AVColorSpace

extension CFFmpeg.AVColorSpace {
    /// order of coefficients is actually GBR, also IEC 61966-2-1 (sRGB)
    public static let RGB = AVCOL_SPC_RGB
    /// also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
    public static let BT709 = AVCOL_SPC_BT709
    public static let UNSPECIFIED = AVCOL_SPC_UNSPECIFIED
    public static let RESERVED = AVCOL_SPC_RESERVED
    /// FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
    public static let FCC = AVCOL_SPC_FCC
    /// also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
    public static let BT470BG = AVCOL_SPC_BT470BG
    /// also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
    public static let SMPTE170M = AVCOL_SPC_SMPTE170M
    /// functionally identical to above
    public static let SMPTE240M = AVCOL_SPC_SMPTE240M
    /// Used by Dirac / VC-2 and H.264 FRext, see ITU-T SG16
    public static let YCGCO = AVCOL_SPC_YCGCO
    public static let YCOCG = AVCOL_SPC_YCOCG
    /// ITU-R BT2020 non-constant luminance system
    public static let BT2020_NCL = AVCOL_SPC_BT2020_NCL
    /// ITU-R BT2020 constant luminance system
    public static let BT2020_CL = AVCOL_SPC_BT2020_CL
    /// SMPTE 2085, Y'D'zD'x
    public static let SMPTE2085 = AVCOL_SPC_SMPTE2085
    /// Chromaticity-derived non-constant luminance system
    public static let CHROMA_DERIVED_NCL = AVCOL_SPC_CHROMA_DERIVED_NCL
    /// Chromaticity-derived constant luminance system
    public static let CHROMA_DERIVED_CL = AVCOL_SPC_CHROMA_DERIVED_CL
    /// ITU-R BT.2100-0, ICtCp
    public static let ICTCP = AVCOL_SPC_ICTCP
    /// Not part of ABI
    public static let NB = AVCOL_SPC_NB

    /// Return the color space corresponding to name.
    ///
    /// If there is no color space with name name, an error is thrown.
    public init?(name: String) throws {
        let range = av_color_space_from_name(name)
        if range < 0 {
            throw AVError(code: range)
        }
        self.init(UInt32(range))
    }

    // The name of the color space.
    public var name: String {
        String(cString: av_color_space_name(self)) ?? "unknown"
    }
}

public typealias AVChromaLocation = CFFmpeg.AVChromaLocation

extension CFFmpeg.AVChromaLocation {
    public static let UNSPECIFIED = AVCHROMA_LOC_UNSPECIFIED
    /// MPEG-2/4 4:2:0, H.264 default for 4:2:0
    public static let LEFT = AVCHROMA_LOC_LEFT
    /// MPEG-1 4:2:0, JPEG 4:2:0, H.263 4:2:0
    public static let CENTER = AVCHROMA_LOC_CENTER
    /// ITU-R 601, SMPTE 274M 296M S314M(DV 4:1:1), mpeg2 4:2:2
    public static let TOPLEFT = AVCHROMA_LOC_TOPLEFT
    public static let TOP = AVCHROMA_LOC_TOP
    public static let BOTTOMLEFT = AVCHROMA_LOC_BOTTOMLEFT
    public static let BOTTOM = AVCHROMA_LOC_BOTTOM
    /// Not part of ABI
    public static let NB = AVCHROMA_LOC_NB

    /// Return the chroma location corresponding to name.
    ///
    /// If there is no chroma location with name name, an error is thrown.
    public init?(name: String) throws {
        let range = av_chroma_location_from_name(name)
        if range < 0 {
            throw AVError(code: range)
        }
        self.init(UInt32(range))
    }

    // The name of the chroma location.
    public var name: String {
        String(cString: av_chroma_location_name(self)) ?? "unknown"
    }
}
