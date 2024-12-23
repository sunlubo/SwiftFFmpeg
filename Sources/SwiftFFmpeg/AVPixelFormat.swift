//
//  AVPixelFormat.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2020/7/1.
//

import CFFmpeg

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
  ///        Y        ,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
  public static let MONOBLACK = AV_PIX_FMT_MONOBLACK
  /// 8 bits with AV_PIX_FMT_RGB32 palette
  public static let PAL8 = AV_PIX_FMT_PAL8
  /// planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV420P and setting color_range
  public static let YUVJ420P = AV_PIX_FMT_YUVJ420P
  /// planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV422P and setting color_range
  public static let YUVJ422P = AV_PIX_FMT_YUVJ422P
  /// planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV444P and setting color_range
  public static let YUVJ444P = AV_PIX_FMT_YUVJ444P
  /// packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
  public static let UYVY422 = AV_PIX_FMT_UYVY422
  /// packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
  public static let UYYVYY411 = AV_PIX_FMT_UYYVYY411
  /// packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
  public static let BGR8 = AV_PIX_FMT_BGR8
  /// packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
  public static let BGR4 = AV_PIX_FMT_BGR4
  /// packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
  public static let BGR4_BYTE = AV_PIX_FMT_BGR4_BYTE
  /// packed RGB 3:3:2,  8bpp, (msb)2R 3G 3B(lsb)
  public static let RGB8 = AV_PIX_FMT_RGB8
  /// packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
  public static let RGB4 = AV_PIX_FMT_RGB4
  /// packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
  public static let RGB4_BYTE = AV_PIX_FMT_RGB4_BYTE
  /// planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
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

  /// Hardware acceleration through VA-API, data[3] contains a VASurfaceID.
  public static let VAAPI = AV_PIX_FMT_VAAPI

  /// planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
  public static let YUV420P16LE = AV_PIX_FMT_YUV420P16LE
  /// planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
  public static let YUV420P16BE = AV_PIX_FMT_YUV420P16BE
  /// planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  public static let YUV422P16LE = AV_PIX_FMT_YUV422P16LE
  /// planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  public static let YUV422P16BE = AV_PIX_FMT_YUV422P16BE
  /// planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
  public static let YUV444P16LE = AV_PIX_FMT_YUV444P16LE
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

  /**
   * The following 12 formats have the disadvantage of needing 1 format for each bit depth.
   * Notice that each 9/10 bits sample is stored in 16 bits with extra padding.
   * If you want to support multiple bit depths, then using AV_PIX_FMT_YUV420P16* with the bpp stored separately is better.
   */
  /// planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
  public static let YUV420P9BE = AV_PIX_FMT_YUV420P9BE
  /// planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
  public static let YUV420P9LE = AV_PIX_FMT_YUV420P9LE
  /// planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
  public static let YUV420P10BE = AV_PIX_FMT_YUV420P10BE
  /// planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
  public static let YUV420P10LE = AV_PIX_FMT_YUV420P10LE
  /// planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  public static let YUV422P10BE = AV_PIX_FMT_YUV422P10BE
  /// planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  public static let YUV422P10LE = AV_PIX_FMT_YUV422P10LE
  /// planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
  public static let YUV444P9BE = AV_PIX_FMT_YUV444P9BE
  /// planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
  public static let YUV444P9LE = AV_PIX_FMT_YUV444P9LE
  /// planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
  public static let YUV444P10BE = AV_PIX_FMT_YUV444P10BE
  /// planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
  public static let YUV444P10LE = AV_PIX_FMT_YUV444P10LE
  /// planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  public static let YUV422P9BE = AV_PIX_FMT_YUV422P9BE
  /// planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  public static let YUV422P9LE = AV_PIX_FMT_YUV422P9LE
  /// planar GBR 4:4:4 24bpp
  public static let GBRP = AV_PIX_FMT_GBRP
  public static let GBR24P = AV_PIX_FMT_GBR24P
  /// planar GBR 4:4:4 27bpp, big-endian
  public static let GBRP9BE = AV_PIX_FMT_GBRP9BE
  /// planar GBR 4:4:4 27bpp, little-endian
  public static let GBRP9LE = AV_PIX_FMT_GBRP9LE
  /// planar GBR 4:4:4 30bpp, big-endian
  public static let GBRP10BE = AV_PIX_FMT_GBRP10BE
  /// planar GBR 4:4:4 30bpp, little-endian
  public static let GBRP10LE = AV_PIX_FMT_GBRP10LE
  /// planar GBR 4:4:4 48bpp, big-endian
  public static let GBRP16BE = AV_PIX_FMT_GBRP16BE
  /// planar GBR 4:4:4 48bpp, little-endian
  public static let GBRP16LE = AV_PIX_FMT_GBRP16LE
  /// planar YUV 4:2:2 24bpp, (1 Cr & Cb sample per 2x1 Y & A samples)
  public static let YUVA422P = AV_PIX_FMT_YUVA422P
  /// planar YUV 4:4:4 32bpp, (1 Cr & Cb sample per 1x1 Y & A samples)
  public static let YUVA444P = AV_PIX_FMT_YUVA444P
  /// planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), big-endian
  public static let YUVA420P9BE = AV_PIX_FMT_YUVA420P9BE
  /// planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), little-endian
  public static let YUVA420P9LE = AV_PIX_FMT_YUVA420P9LE
  /// planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), big-endian
  public static let YUVA422P9BE = AV_PIX_FMT_YUVA422P9BE
  /// planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), little-endian
  public static let YUVA422P9LE = AV_PIX_FMT_YUVA422P9LE
  /// planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
  public static let YUVA444P9BE = AV_PIX_FMT_YUVA444P9BE
  /// planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
  public static let YUVA444P9LE = AV_PIX_FMT_YUVA444P9LE
  /// planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
  public static let YUVA420P10BE = AV_PIX_FMT_YUVA420P10BE
  /// planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
  public static let YUVA420P10LE = AV_PIX_FMT_YUVA420P10LE
  /// planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
  public static let YUVA422P10BE = AV_PIX_FMT_YUVA422P10BE
  /// planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
  public static let YUVA422P10LE = AV_PIX_FMT_YUVA422P10LE
  /// planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
  public static let YUVA444P10BE = AV_PIX_FMT_YUVA444P10BE
  /// planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
  public static let YUVA444P10LE = AV_PIX_FMT_YUVA444P10LE
  /// planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
  public static let YUVA420P16BE = AV_PIX_FMT_YUVA420P16BE
  /// planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
  public static let YUVA420P16LE = AV_PIX_FMT_YUVA420P16LE
  /// planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
  public static let YUVA422P16BE = AV_PIX_FMT_YUVA422P16BE
  /// planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
  public static let YUVA422P16LE = AV_PIX_FMT_YUVA422P16LE
  /// planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
  public static let YUVA444P16BE = AV_PIX_FMT_YUVA444P16BE
  /// planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
  public static let YUVA444P16LE = AV_PIX_FMT_YUVA444P16LE

  /// HW acceleration through VDPAU, Picture.data[3] contains a VdpVideoSurface
  public static let VDPAU = AV_PIX_FMT_VDPAU

  /// packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as little-endian, the 4 lower bits are set to 0
  public static let XYZ12LE = AV_PIX_FMT_XYZ12LE
  /// packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as big-endian, the 4 lower bits are set to 0
  public static let XYZ12BE = AV_PIX_FMT_XYZ12BE
  /// interleaved chroma YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
  public static let NV16 = AV_PIX_FMT_NV16
  /// interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  public static let NV20LE = AV_PIX_FMT_NV20LE
  /// interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  public static let NV20BE = AV_PIX_FMT_NV20BE

  /// packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
  public static let RGBA64BE = AV_PIX_FMT_RGBA64BE
  /// packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
  public static let RGBA64LE = AV_PIX_FMT_RGBA64LE
  /// packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
  public static let BGRA64BE = AV_PIX_FMT_BGRA64BE
  /// packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
  public static let BGRA64LE = AV_PIX_FMT_BGRA64LE

  /// packed YUV 4:2:2, 16bpp, Y0 Cr Y1 Cb
  public static let YVYU422 = AV_PIX_FMT_YVYU422

  /// 16 bits gray, 16 bits alpha (big-endian)
  public static let YA16BE = AV_PIX_FMT_YA16BE
  /// 16 bits gray, 16 bits alpha (little-endian)
  public static let YA16LE = AV_PIX_FMT_YA16LE

  /// planar GBRA 4:4:4:4 32bpp
  public static let GBRAP = AV_PIX_FMT_GBRAP
  /// planar GBRA 4:4:4:4 64bpp, big-endian
  public static let GBRAP16BE = AV_PIX_FMT_GBRAP16BE
  /// planar GBRA 4:4:4:4 64bpp, little-endian
  public static let GBRAP16LE = AV_PIX_FMT_GBRAP16LE
  /**
   *  HW acceleration through QSV, data[3] contains a pointer to the
   *  mfxFrameSurface1 structure.
   */
  public static let QSV = AV_PIX_FMT_QSV
  /**
   * HW acceleration though MMAL, data[3] contains a pointer to the
   * MMAL_BUFFER_HEADER_T structure.
   */
  public static let MMAL = AV_PIX_FMT_MMAL

  /// HW decoding through Direct3D11 via old API, Picture.data[3] contains a ID3D11VideoDecoderOutputView pointer
  public static let D3D11VA_VLD = AV_PIX_FMT_D3D11VA_VLD

  /**
   * HW acceleration through CUDA. data[i] contain CUdeviceptr pointers
   * exactly as for system memory frames.
   */
  public static let CUDA = AV_PIX_FMT_CUDA

  /// packed RGB 8:8:8, 32bpp, XRGBXRGB...   X=unused/undefined
  public static let _0RGB = AV_PIX_FMT_0RGB
  /// packed RGB 8:8:8, 32bpp, RGBXRGBX...   X=unused/undefined
  public static let RGB0 = AV_PIX_FMT_RGB0
  /// packed BGR 8:8:8, 32bpp, XBGRXBGR...   X=unused/undefined
  public static let _0BGR = AV_PIX_FMT_0BGR
  /// packed BGR 8:8:8, 32bpp, BGRXBGRX...   X=unused/undefined
  public static let BGR0 = AV_PIX_FMT_BGR0

  /// planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
  public static let YUV420P12BE = AV_PIX_FMT_YUV420P12BE
  /// planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
  public static let YUV420P12LE = AV_PIX_FMT_YUV420P12LE
  /// planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
  public static let YUV420P14BE = AV_PIX_FMT_YUV420P14BE
  /// planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
  public static let YUV420P14LE = AV_PIX_FMT_YUV420P14LE
  /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  public static let YUV422P12BE = AV_PIX_FMT_YUV422P12BE
  /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  public static let YUV422P12LE = AV_PIX_FMT_YUV422P12LE
  /// planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  public static let YUV422P14BE = AV_PIX_FMT_YUV422P14BE
  /// planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  public static let YUV422P14LE = AV_PIX_FMT_YUV422P14LE
  /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
  public static let YUV444P12BE = AV_PIX_FMT_YUV444P12BE
  /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
  public static let YUV444P12LE = AV_PIX_FMT_YUV444P12LE
  /// planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
  public static let YUV444P14BE = AV_PIX_FMT_YUV444P14BE
  /// planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
  public static let YUV444P14LE = AV_PIX_FMT_YUV444P14LE
  /// planar GBR 4:4:4 36bpp, big-endian
  public static let GBRP12BE = AV_PIX_FMT_GBRP12BE
  /// planar GBR 4:4:4 36bpp, little-endian
  public static let GBRP12LE = AV_PIX_FMT_GBRP12LE
  /// planar GBR 4:4:4 42bpp, big-endian
  public static let GBRP14BE = AV_PIX_FMT_GBRP14BE
  /// planar GBR 4:4:4 42bpp, little-endian
  public static let GBRP14LE = AV_PIX_FMT_GBRP14LE
  /// planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples) full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV411P and setting color_range
  public static let YUVJ411P = AV_PIX_FMT_YUVJ411P

  /// bayer, BGBG..(odd line), GRGR..(even line), 8-bit samples */
  public static let BAYER_BGGR8 = AV_PIX_FMT_BAYER_BGGR8
  /// bayer, RGRG..(odd line), GBGB..(even line), 8-bit samples */
  public static let BAYER_RGGB8 = AV_PIX_FMT_BAYER_RGGB8
  /// bayer, GBGB..(odd line), RGRG..(even line), 8-bit samples */
  public static let BAYER_GBRG8 = AV_PIX_FMT_BAYER_GBRG8
  /// bayer, GRGR..(odd line), BGBG..(even line), 8-bit samples */
  public static let BAYER_GRBG8 = AV_PIX_FMT_BAYER_GRBG8
  /// bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, little-endian */
  public static let BAYER_BGGR16LE = AV_PIX_FMT_BAYER_BGGR16LE
  /// bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, big-endian */
  public static let BAYER_BGGR16BE = AV_PIX_FMT_BAYER_BGGR16BE
  /// bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, little-endian */
  public static let BAYER_RGGB16LE = AV_PIX_FMT_BAYER_RGGB16LE
  /// bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, big-endian */
  public static let BAYER_RGGB16BE = AV_PIX_FMT_BAYER_RGGB16BE
  /// bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, little-endian */
  public static let BAYER_GBRG16LE = AV_PIX_FMT_BAYER_GBRG16LE
  /// bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, big-endian */
  public static let BAYER_GBRG16BE = AV_PIX_FMT_BAYER_GBRG16BE
  /// bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, little-endian */
  public static let BAYER_GRBG16LE = AV_PIX_FMT_BAYER_GRBG16LE
  /// bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, big-endian */
  public static let BAYER_GRBG16BE = AV_PIX_FMT_BAYER_GRBG16BE

  /// planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
  public static let YUV440P10LE = AV_PIX_FMT_YUV440P10LE
  /// planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
  public static let YUV440P10BE = AV_PIX_FMT_YUV440P10BE
  /// planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
  public static let YUV440P12LE = AV_PIX_FMT_YUV440P12LE
  /// planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
  public static let YUV440P12BE = AV_PIX_FMT_YUV440P12BE
  /// packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
  public static let AYUV64LE = AV_PIX_FMT_AYUV64LE
  /// packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
  public static let AYUV64BE = AV_PIX_FMT_AYUV64BE

  /// hardware decoding through Videotoolbox
  public static let VIDEOTOOLBOX = AV_PIX_FMT_VIDEOTOOLBOX

  /// like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, little-endian
  public static let P010LE = AV_PIX_FMT_P010LE
  /// like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, big-endian
  public static let P010BE = AV_PIX_FMT_P010BE

  /// planar GBR 4:4:4:4 48bpp, big-endian
  public static let GBRAP12BE = AV_PIX_FMT_GBRAP12BE
  /// planar GBR 4:4:4:4 48bpp, little-endian
  public static let GBRAP12LE = AV_PIX_FMT_GBRAP12LE

  /// planar GBR 4:4:4:4 40bpp, big-endian
  public static let GBRAP10BE = AV_PIX_FMT_GBRAP10BE
  /// planar GBR 4:4:4:4 40bpp, little-endian
  public static let GBRAP10LE = AV_PIX_FMT_GBRAP10LE

  /// hardware decoding through MediaCodec
  public static let MEDIACODEC = AV_PIX_FMT_MEDIACODEC

  ///        Y        , 12bpp, big-endian
  public static let GRAY12BE = AV_PIX_FMT_GRAY12BE
  ///        Y        , 12bpp, little-endian
  public static let GRAY12LE = AV_PIX_FMT_GRAY12LE
  ///        Y        , 10bpp, big-endian
  public static let GRAY10BE = AV_PIX_FMT_GRAY10BE
  ///        Y        , 10bpp, little-endian
  public static let GRAY10LE = AV_PIX_FMT_GRAY10LE

  /// like NV12, with 16bpp per component, little-endian
  public static let P016LE = AV_PIX_FMT_P016LE
  /// like NV12, with 16bpp per component, big-endian
  public static let P016BE = AV_PIX_FMT_P016BE

  /**
   * Hardware surfaces for Direct3D11.
   *
   * This is preferred over the legacy AV_PIX_FMT_D3D11VA_VLD. The new D3D11
   * hwaccel API and filtering support AV_PIX_FMT_D3D11 only.
   *
   * data[0] contains a ID3D11Texture2D pointer, and data[1] contains the
   * texture array index of the frame as intptr_t if the ID3D11Texture2D is
   * an array texture (or always 0 if it's a normal texture).
   */
  public static let D3D11 = AV_PIX_FMT_D3D11

  ///        Y        , 9bpp, big-endian
  public static let GRAY9BE = AV_PIX_FMT_GRAY9BE
  ///        Y        , 9bpp, little-endian
  public static let GRAY9LE = AV_PIX_FMT_GRAY9LE

  /// IEEE-754 single precision planar GBR 4:4:4,     96bpp, big-endian
  public static let GBRPF32BE = AV_PIX_FMT_GBRPF32BE
  /// IEEE-754 single precision planar GBR 4:4:4,     96bpp, little-endian
  public static let GBRPF32LE = AV_PIX_FMT_GBRPF32LE
  /// IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, big-endian
  public static let GBRAPF32BE = AV_PIX_FMT_GBRAPF32BE
  /// IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, little-endian
  public static let GBRAPF32LE = AV_PIX_FMT_GBRAPF32LE

  /**
   * DRM-managed buffers exposed through PRIME buffer sharing.
   *
   * data[0] points to an AVDRMFrameDescriptor.
   */
  public static let DRM_PRIME = AV_PIX_FMT_DRM_PRIME
  /**
   * Hardware surfaces for OpenCL.
   *
   * data[i] contain 2D image objects (typed in C as cl_mem, used
   * in OpenCL as image2d_t) for each plane of the surface.
   */
  public static let OPENCL = AV_PIX_FMT_OPENCL

  ///        Y        , 14bpp, big-endian
  public static let GRAY14BE = AV_PIX_FMT_GRAY14BE
  ///        Y        , 14bpp, little-endian
  public static let GRAY14LE = AV_PIX_FMT_GRAY14LE

  /// IEEE-754 single precision Y, 32bpp, big-endian
  public static let GRAYF32BE = AV_PIX_FMT_GRAYF32BE
  /// IEEE-754 single precision Y, 32bpp, little-endian
  public static let GRAYF32LE = AV_PIX_FMT_GRAYF32LE

  /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, big-endian
  public static let YUVA422P12BE = AV_PIX_FMT_YUVA422P12BE
  /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, little-endian
  public static let YUVA422P12LE = AV_PIX_FMT_YUVA422P12LE
  /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, big-endian
  public static let YUVA444P12BE = AV_PIX_FMT_YUVA444P12BE
  /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, little-endian
  public static let YUVA444P12LE = AV_PIX_FMT_YUVA444P12LE

  /// planar YUV 4:4:4, 24bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
  public static let NV24 = AV_PIX_FMT_NV24
  /// as above, but U and V bytes are swapped
  public static let NV42 = AV_PIX_FMT_NV42

  /// Return the pixel format corresponding to name.
  ///
  /// If there is no pixel format with name name, then looks for a pixel format with the name
  /// corresponding to the native endian format of name.
  /// For example in a little-endian system, first looks for "gray16", then for "gray16le".
  ///
  /// Finally if no pixel format has been found, returns `nil`.
  public init?(name: String) {
    let type = av_get_pix_fmt(name)
    guard type != .none else {
      return nil
    }
    self = type
  }

  // The name of the pixel format.
  public var name: String {
    String(cString: av_get_pix_fmt_name(self)) ?? "unknown"
  }

  /// The number of planes in the pixel format.
  public var planeCount: Int {
    max(Int(av_pix_fmt_count_planes(self)), 0)
  }

  /// The pixel format descriptor of the pixel format.
  public var descriptor: AVPixelFormatDescriptor? {
    av_pix_fmt_desc_get(self).map(AVPixelFormatDescriptor.init(native:))
  }
}

// MARK: - AVColorPrimaries

/// Chromaticity coordinates of the source primaries.
/// These values match the ones defined by ISO/IEC 23001-8_2013 § 7.1.
public enum AVColorPrimaries: UInt32 {
  case RESERVED0
  /// also ITU-R BT1361 / IEC 61966-2-4 / SMPTE RP177 Annex B
  case BT709
  case UNSPECIFIED
  case RESERVED
  /// also FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
  case BT470M
  /// also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM
  case BT470BG
  /// also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
  case SMPTE170M
  /// functionally identical to above
  case SMPTE240M
  /// colour filters using Illuminant C
  case FILM
  /// ITU-R BT2020
  case BT2020
  /// SMPTE ST 428-1 (CIE 1931 XYZ)
  case SMPTEST428_1 // SMPTE428
  /// SMPTE ST 431-2 (2011) / DCI P3
  case SMPTE431
  /// SMPTE ST 432-1 (2010) / P3 D65 / Display P3
  case SMPTE432
  /// EBU Tech. 3213-E / JEDEC P22 phosphors
  case JEDEC_P22 // EBU3213

  var native: CFFmpeg.AVColorPrimaries {
    CFFmpeg.AVColorPrimaries(rawValue)
  }

  init(native: CFFmpeg.AVColorPrimaries) {
    guard let primaries = AVColorPrimaries(rawValue: native.rawValue) else {
      fatalError("Unknown color primaries: \(native)")
    }
    self = primaries
  }

  /// Return the color primaries corresponding to name, or `nil` if the color primaries does not exist.
  ///
  /// - Parameter name: The name of the color primaries.
  public init?(name: String) {
    let primaries = av_color_primaries_from_name(name)
    guard primaries >= 0 else {
      return nil
    }
    self = AVColorPrimaries(rawValue: UInt32(primaries))!
  }

  // The name of the color primaries.
  public var name: String {
    String(cString: av_color_primaries_name(native))
  }
}

// MARK: - AVColorTransferCharacteristic

/// Color Transfer Characteristic.
/// These values match the ones defined by ISO/IEC 23001-8_2013 § 7.2.
public enum AVColorTransferCharacteristic: UInt32 {
  case RESERVED0
  /// also ITU-R BT1361
  case BT709
  case UNSPECIFIED
  case RESERVED
  /// also ITU-R BT470M / ITU-R BT1700 625 PAL & SECAM
  case GAMMA22
  /// also ITU-R BT470BG
  case GAMMA28
  /// also ITU-R BT601-6 525 or 625 / ITU-R BT1358 525 or 625 / ITU-R BT1700 NTSC
  case SMPTE170M
  case SMPTE240M
  /// "Linear transfer characteristics"
  case LINEAR
  /// "Logarithmic transfer characteristic (100:1 range)"
  case LOG
  /// "Logarithmic transfer characteristic (100 * Sqrt(10) : 1 range)"
  case LOG_SQRT
  /// IEC 61966-2-4
  case IEC61966_2_4
  /// ITU-R BT1361 Extended Colour Gamut
  case BT1361_ECG
  /// IEC 61966-2-1 (sRGB or sYCC)
  case IEC61966_2_1
  /// ITU-R BT2020 for 10-bit system
  case BT2020_10
  /// ITU-R BT2020 for 12-bit system
  case BT2020_12
  /// SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems
  case SMPTEST2084 // SMPTE2084
  /// SMPTE ST 428-1
  case SMPTEST428_1 // SMPTE428
  /// ARIB STD-B67, known as "Hybrid log-gamma"
  case ARIB_STD_B67

  var native: CFFmpeg.AVColorTransferCharacteristic {
    CFFmpeg.AVColorTransferCharacteristic(rawValue)
  }

  init(native: CFFmpeg.AVColorTransferCharacteristic) {
    guard let transfer = AVColorTransferCharacteristic(rawValue: native.rawValue) else {
      fatalError("Unknown color transfer characteristic: \(native)")
    }
    self = transfer
  }

  /// Return the color transfer characteristic corresponding to name, or `nil` if the color transfer characteristic does not exist.
  ///
  /// - Parameter name: The name of the color transfer characteristic.
  public init?(name: String) {
    let transfer = av_color_transfer_from_name(name)
    guard transfer >= 0 else {
      return nil
    }
    self = AVColorTransferCharacteristic(rawValue: UInt32(transfer))!
  }

  // The name of the color transfer characteristic.
  public var name: String {
    String(cString: av_color_transfer_name(native))
  }
}

// MARK: - AVColorSpace

/// YUV colorspace type.
/// These values match the ones defined by ISO/IEC 23001-8_2013 § 7.3.
public enum AVColorSpace: UInt32 {
  /// order of coefficients is actually GBR, also IEC 61966-2-1 (sRGB)
  case RGB
  /// also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
  case BT709
  case UNSPECIFIED
  case RESERVED
  /// FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
  case FCC
  /// also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
  case BT470BG
  /// also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
  case SMPTE170M
  /// functionally identical to above
  case SMPTE240M
  /// Used by Dirac / VC-2 and H.264 FRext, see ITU-T SG16
  case YCOCG // YCGCO
  /// ITU-R BT2020 non-constant luminance system
  case BT2020_NCL
  /// ITU-R BT2020 constant luminance system
  case BT2020_CL
  /// SMPTE 2085, Y'D'zD'x
  case SMPTE2085
  /// Chromaticity-derived non-constant luminance system
  case CHROMA_DERIVED_NCL
  /// Chromaticity-derived constant luminance system
  case CHROMA_DERIVED_CL
  /// ITU-R BT.2100-0, ICtCp
  case ICTCP

  var native: CFFmpeg.AVColorSpace {
    CFFmpeg.AVColorSpace(rawValue)
  }

  init(native: CFFmpeg.AVColorSpace) {
    guard let space = AVColorSpace(rawValue: native.rawValue) else {
      fatalError("Unknown color space: \(native)")
    }
    self = space
  }

  /// Return the color space corresponding to name, or `nil` if the color space does not exist.
  ///
  /// - Parameter name: The name of the color space.
  public init?(name: String) {
    let space = av_color_space_from_name(name)
    guard space >= 0 else {
      return nil
    }
    self = AVColorSpace(rawValue: UInt32(space))!
  }

  // The name of the color space.
  public var name: String {
    String(cString: av_color_space_name(native))
  }
}

// MARK: - AVColorRange

/// MPEG vs JPEG YUV range.
public enum AVColorRange: UInt32 {
  case unspecified
  /// The normal 219*2^(n-8) "MPEG" YUV ranges - also known as "Legal" or "Video" range
  case mpeg
  /// The normal     2^n-1   "JPEG" YUV ranges - also known as "Full" range
  case jpeg

  var native: CFFmpeg.AVColorRange {
    CFFmpeg.AVColorRange(rawValue)
  }

  init(native: CFFmpeg.AVColorRange) {
    guard let range = AVColorRange(rawValue: native.rawValue) else {
      fatalError("Unknown color range: \(native)")
    }
    self = range
  }

  /// Return the color range corresponding to name, or `nil` if the color range does not exist.
  ///
  /// - Parameter name: The name of the color range.
  public init?(name: String) {
    let range = av_color_range_from_name(name)
    guard range >= 0 else {
      return nil
    }
    self = AVColorRange(rawValue: UInt32(range))!
  }

  // The name of the color range.
  public var name: String {
    String(cString: av_color_range_name(native))
  }
}

// MARK: - AVChromaLocation

/// Location of chroma samples.
///
/// Illustration showing the location of the first (top left) chroma sample of the
/// image, the left shows only luma, the right
/// shows the location of the chroma sample, the 2 could be imagined to overlay
/// each other but are drawn separately due to limitations of ASCII
///
///                1st 2nd       1st 2nd horizontal luma sample positions
///                 v   v         v   v
///                 ______        ______
/// *1st luma line > |X   X ...    |3 4 X ...     X are luma samples,
///                |             |1 2           1-6 are possible chroma positions
/// *2nd luma line > |X   X ...    |5 6 X ...     0 is undefined/unknown position
public enum AVChromaLocation: UInt32 {
  case unspecified
  /// MPEG-2/4 4:2:0, H.264 default for 4:2:0
  case left
  /// MPEG-1 4:2:0, JPEG 4:2:0, H.263 4:2:0
  case center
  /// ITU-R 601, SMPTE 274M 296M S314M(DV 4:1:1), mpeg2 4:2:2
  case topLeft
  case top
  case bottomLeft
  case bottom

  var native: CFFmpeg.AVChromaLocation {
    CFFmpeg.AVChromaLocation(rawValue)
  }

  init(native: CFFmpeg.AVChromaLocation) {
    guard let location = AVChromaLocation(rawValue: native.rawValue) else {
      fatalError("Unknown chroma location: \(native)")
    }
    self = location
  }

  /// Return the chroma location corresponding to name, or `nil` if the chroma location does not exist.
  ///
  /// - Parameter name: The name of the chroma location.
  public init?(name: String) {
    let range = av_chroma_location_from_name(name)
    guard range >= 0 else {
      return nil
    }
    self = AVChromaLocation(rawValue: UInt32(range))!
  }

  // The name of the chroma location.
  public var name: String {
    String(cString: av_chroma_location_name(native))
  }
}
