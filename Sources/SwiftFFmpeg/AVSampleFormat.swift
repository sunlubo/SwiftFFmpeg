//
//  AVSampleFormat.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2020/7/1.
//

import CFFmpeg

/// Audio sample formats
///
/// - The data described by the sample format is always in native-endian order.
///   Sample values can be expressed by native C types, hence the lack of a signed
///   24-bit sample format even though it is a common raw audio data format.
///
/// - The floating-point formats are based on full volume being in the range
///   [-1.0, 1.0]. Any values outside this range are beyond full volume level.
///
/// - The data layout as used in av_samples_fill_arrays() and elsewhere in FFmpeg
///   (such as AVFrame in libavcodec) is as follows:
///
/// For planar sample formats, each audio channel is in a separate data plane,
/// and linesize is the buffer size, in bytes, for a single plane. All data
/// planes must be the same size. For packed sample formats, only the first data
/// plane is used, and samples for each channel are interleaved. In this case,
/// linesize is the buffer size, in bytes, for the 1 plane.
public enum AVSampleFormat: Int32 {
  case none = -1 // AV_SAMPLE_FMT_NONE
  /// unsigned 8 bits
  case uint8 = 0 // AV_SAMPLE_FMT_U8
  /// signed 16 bits
  case int16 // AV_SAMPLE_FMT_S16
  /// signed 32 bits
  case int32 // AV_SAMPLE_FMT_S32
  /// float
  case float // AV_SAMPLE_FMT_FLT
  /// double
  case double // AV_SAMPLE_FMT_DBL
  /// unsigned 8 bits, planar
  case uint8Planar // AV_SAMPLE_FMT_U8P
  /// signed 16 bits, planar
  case int16Planar // AV_SAMPLE_FMT_S16P
  /// signed 32 bits, planar
  case int32Planar // AV_SAMPLE_FMT_S32P
  /// float, planar
  case floatPlanar // AV_SAMPLE_FMT_FLTP
  /// double, planar
  case doublePlanar // AV_SAMPLE_FMT_DBLP
  /// signed 64 bits
  case int64 // AV_SAMPLE_FMT_S64
  /// signed 64 bits, planar
  case int64Planar // AV_SAMPLE_FMT_S64P

  var native: CFFmpeg.AVSampleFormat {
    CFFmpeg.AVSampleFormat(rawValue)
  }

  init(native: CFFmpeg.AVSampleFormat) {
    guard let format = AVSampleFormat(rawValue: native.rawValue) else {
      fatalError("Unknown sample format: \(native)")
    }
    self = format
  }

  /// Return a sample format corresponding to name, or `nil` if the sample format does not exist.
  ///
  /// - Parameter name: The name of the sample format.
  public init?(name: String) {
    let format = av_get_sample_fmt(name)
    guard format != AV_SAMPLE_FMT_NONE else {
      return nil
    }
    self = AVSampleFormat(native: format)
  }

  /// The name of the sample format, or `nil` if sample format is not recognized.
  public var name: String? {
    String(cString: av_get_sample_fmt_name(native))
  }

  /// The number of bytes per sample or zero if unknown for the given sample format.
  public var bytesPerSample: Int {
    Int(av_get_bytes_per_sample(native))
  }

  /// A Boolean value indicating whether the sample format is planar.
  public var isPlanar: Bool {
    av_sample_fmt_is_planar(native) == 1
  }

  /// Return the planar alternative form of the given sample format, or `nil` if the planar sample format does not exist.
  ///
  /// If the passed sample format is already in planar format, the format returned is the same as the input.
  public func toPlanar() -> AVSampleFormat? {
    let format = av_get_planar_sample_fmt(native)
    guard format != AV_SAMPLE_FMT_NONE else {
      return nil
    }
    return AVSampleFormat(native: format)
  }

  /// Return the packed alternative form of the given sample format, or `nil` if the packed sample format does not exist.
  ///
  /// If the passed sample format is already in packed format, the format returned is the same as the input.
  public func toPacked() -> AVSampleFormat? {
    let format = av_get_packed_sample_fmt(native)
    guard format != AV_SAMPLE_FMT_NONE else {
      return nil
    }
    return AVSampleFormat(native: format)
  }
}

extension AVSampleFormat: CustomStringConvertible {
  public var description: String {
    name ?? "unknown"
  }
}
