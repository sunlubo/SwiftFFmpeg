//
//  VideoUtil.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/2.
//

import CFFmpeg

// MARK: - AVPictureType

public enum AVPictureType: UInt32 {
  /// Undefined
  case none = 0
  /// Intra
  case I
  /// Predicted
  case P
  /// Bi-dir predicted
  case B
  /// S(GMC)-VOP MPEG-4
  case S
  /// Switching Intra
  case SI
  /// Switching Predicted
  case SP
  /// BI type
  case BI

  var native: CFFmpeg.AVPictureType {
    CFFmpeg.AVPictureType(rawValue)
  }

  init(native: CFFmpeg.AVPictureType) {
    guard let type = AVPictureType(rawValue: native.rawValue) else {
      fatalError("Unknown picture type: \(native)")
    }
    self = type
  }
}

// MARK: - AVPictureType + CustomStringConvertible

extension AVPictureType: CustomStringConvertible {

  public var description: String {
    let char = av_get_picture_type_char(native)
    let scalar = Unicode.Scalar(Int(char))!
    return String(Character(scalar))
  }
}

public typealias AVComponentDescriptor = CFFmpeg.AVComponentDescriptor

public struct AVPixelFormatDescriptor {
  let native: UnsafePointer<AVPixFmtDescriptor>

  init(native: UnsafePointer<AVPixFmtDescriptor>) {
    self.native = native
  }

  /// The name of the pixel format descriptor.
  public var name: String {
    String(cString: native.pointee.name) ?? "unknown"
  }

  /// The number of components each pixel has, (1-4)
  public var numberOfComponents: Int {
    Int(native.pointee.nb_components)
  }

  /// Amount to shift the luma width right to find the chroma width.
  /// For YV12 this is 1 for example.
  /// chroma_width = AV_CEIL_RSHIFT(luma_width, log2_chroma_w)
  /// The note above is needed to ensure rounding up.
  /// This value only refers to the chroma components.
  public var log2ChromaW: Int {
    Int(native.pointee.log2_chroma_w)
  }

  /// Amount to shift the luma height right to find the chroma height.
  /// For YV12 this is 1 for example.
  /// chroma_height= AV_CEIL_RSHIFT(luma_height, log2_chroma_h)
  /// The note above is needed to ensure rounding up.
  /// This value only refers to the chroma components.
  public var log2ChromaH: Int {
    Int(native.pointee.log2_chroma_h)
  }

  /// Parameters that describe how pixels are packed.
  /// If the format has 1 or 2 components, then luma is 0.
  /// If the format has 3 or 4 components:
  ///   if the RGB flag is set then 0 is red, 1 is green and 2 is blue;
  ///   otherwise 0 is luma, 1 is chroma-U and 2 is chroma-V.
  ///
  /// If present, the Alpha channel is always the last component.
  public var componentDescriptors: [SwiftFFmpeg.AVComponentDescriptor] {
    [native.pointee.comp.0, native.pointee.comp.1, native.pointee.comp.2, native.pointee.comp.3]
  }

  /// A wrapper around the C property for flags, containing AV_PIX_FMT_FLAG constants in a option set.
  public var flags: AVPixelFormatFlags {
    AVPixelFormatFlags(rawValue: native.pointee.flags)
  }

  /// Alternative comma-separated names.
  public var alias: String? {
    String(cString: native.pointee.alias)
  }

  /// Return the number of bits per pixel used by the pixel format
  /// described by pixdesc. Note that this is not the same as the number
  /// of bits per sample.
  /// The returned number of bits refers to the number of bits actually
  /// used for storing the pixel information, that is padding bits are
  /// not counted.
  public var bitsPerPixel: Int {
    Int(av_get_bits_per_pixel(native))
  }

  /// Return the number of bits per pixel for the pixel format described by pixdesc, including any padding or unused bits.
  public var bitsPerPixelPadded: Int {
    Int(av_get_padded_bits_per_pixel(native))
  }

  /// @return an AVPixelFormat id described by desc, or AV_PIX_FMT_NONE if desc
  /// is not a valid pointer to a pixel format descriptor.
  public var id: AVPixelFormat {
    av_pix_fmt_desc_get_id(native)
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

extension AVPixelFormat: @retroactive CustomStringConvertible {

  public var description: String {
    name
  }
}

public typealias AVFieldOrder = CFFmpeg.AVFieldOrder

extension CFFmpeg.AVFieldOrder {
  public static let UNKNOWN = AV_FIELD_UNKNOWN

  public static let PROGRESSIVE = AV_FIELD_PROGRESSIVE

  /// Top coded_first, top displayed first
  public static let TT = AV_FIELD_TT

  /// Bottom coded first, bottom displayed first
  public static let BB = AV_FIELD_BB

  /// Top coded first, bottom displayed first
  public static let TB = AV_FIELD_TB

  /// Bottom coded first, top displayed first
  public static let BT = AV_FIELD_BT
}
