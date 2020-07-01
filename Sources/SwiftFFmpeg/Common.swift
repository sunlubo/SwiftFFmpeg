//
//  CType.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/4.
//

import CFFmpeg

// MARK: - AVMediaType

public typealias AVMediaType = CFFmpeg.AVMediaType

extension AVMediaType {
  /// Usually treated as `data`
  public static let unknown = AVMEDIA_TYPE_UNKNOWN
  public static let video = AVMEDIA_TYPE_VIDEO
  public static let audio = AVMEDIA_TYPE_AUDIO
  /// Opaque data information usually continuous
  public static let data = AVMEDIA_TYPE_DATA
  public static let subtitle = AVMEDIA_TYPE_SUBTITLE
  /// Opaque data information usually sparse
  public static let attachment = AVMEDIA_TYPE_ATTACHMENT
}

extension AVMediaType: CustomStringConvertible {

  public var description: String {
    String(cString: av_get_media_type_string(self)) ?? "unknown"
  }
}

public enum FFmpeg {

  /// Do global initialization of network libraries.
  /// This is optional, and not recommended anymore.
  ///
  /// This functions only exists to work around thread-safety issues
  /// with older GnuTLS or OpenSSL libraries. If libavformat is linked
  /// to newer versions of those libraries, or if you do not use them,
  /// calling this function is unnecessary. Otherwise, you need to call
  /// this function before any other threads using them are started.
  ///
  /// This function will be deprecated once support for older GnuTLS and
  /// OpenSSL libraries is removed, and this function has no purpose
  /// anymore.
  public static func networkInit() throws {
    try throwIfFail(avformat_network_init())
  }

  /// Undo the initialization done by `networkInit()`.
  /// Call it only once for each time you called `networkInit()`.
  public static func networkDeinit() {
    avformat_network_deinit()
  }
}
