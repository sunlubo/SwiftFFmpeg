//
//  MasteringDisplayMetadata.swift
//  SwiftFFmpeg
//
//  Created by Greg Cotten on 4/1/20.
//
//

import CFFmpeg

public typealias CAVMasteringDisplayMetadata = CFFmpeg.AVMasteringDisplayMetadata

public struct AVMasteringDisplayMetadata {

  /// CIE 1931 xy chromaticity coords of color primaries (r, g, b order).
  public var display_primaries: [[AVRational]]

  /// CIE 1931 xy chromaticity coords of white point.
  public var white_point: [AVRational]

  /// Min luminance of mastering display (cd/m^2).
  public var min_luminance: AVRational

  /// Max luminance of mastering display (cd/m^2).
  public var max_luminance: AVRational

  /// Flag indicating whether the display primaries (and white point) are set.
  public var has_primaries: Bool

  /// Flag indicating whether the luminance (min_ and max_) have been set.
  public var has_luminance: Bool

  init(cMasteringDisplayMetadata cData: CAVMasteringDisplayMetadata) {
    display_primaries = [[cData.display_primaries.0.0, cData.display_primaries.0.1], [cData.display_primaries.1.0, cData.display_primaries.1.1], [cData.display_primaries.2.0, cData.display_primaries.2.1]]
    white_point = [cData.white_point.0, cData.white_point.1]

    min_luminance = cData.min_luminance

    max_luminance = cData.max_luminance

    has_primaries = cData.has_primaries == 1

    has_luminance = cData.has_luminance == 1
  }
}

public extension AVFrameSideData {
  var masteringDisplayMetadata: AVMasteringDisplayMetadata? {
    guard type == .masteringDisplayMetadata else { return nil }

    return data.withMemoryRebound(to: CAVMasteringDisplayMetadata.self, capacity: 1) { cMasteringDisplayMetadata -> AVMasteringDisplayMetadata in
      .init(cMasteringDisplayMetadata: cMasteringDisplayMetadata.pointee)
    }
  }
}

public typealias CAVContentLightMetadata = CFFmpeg.AVContentLightMetadata

/// Content light level needed by to transmit HDR over HDMI (CTA-861.3).
/// To be used as payload of a AVFrameSideData or AVPacketSideData with the
/// appropriate type.
/// @note The struct should be allocated with av_content_light_metadata_alloc()
///       and its size is not a part of the public ABI.
public struct AVContentLightMetadata {
  /// Max content light level (cd/m^2).
  public var maxFALL: UInt32

  /// Max average light level per frame (cd/m^2).
  public var maxCLL: UInt32

  init(cContentLightMetadata cData: CAVContentLightMetadata) {
    maxFALL = cData.MaxFALL
    maxCLL = cData.MaxCLL
  }
}

public extension AVFrameSideData {
  var contentLightMetadata: AVContentLightMetadata? {
    guard type == .contentLightLevel else { return nil }

    return data.withMemoryRebound(to: CAVContentLightMetadata.self, capacity: 1) { cContentLightMetadata -> AVContentLightMetadata in
      .init(cContentLightMetadata: cContentLightMetadata.pointee)
    }
  }
}
