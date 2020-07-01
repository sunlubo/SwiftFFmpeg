//
//  CType.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/4.
//

import CFFmpeg

// MARK: - AVMediaType

public enum AVMediaType: Int32 {
  /// Usually treated as `data`
  case unknown = -1
  case video
  case audio
  /// Opaque data information usually continuous
  case data
  case subtitle
  /// Opaque data information usually sparse
  case attachment

  internal var native: CFFmpeg.AVMediaType {
    CFFmpeg.AVMediaType(rawValue)
  }

  internal init(native: CFFmpeg.AVMediaType) {
    guard let type = AVMediaType(rawValue: native.rawValue) else {
      fatalError("Unknown media type: \(native)")
    }
    self = type
  }
}

// MARK: - AVMediaType + CustomStringConvertible

extension AVMediaType: CustomStringConvertible {

  public var description: String {
    String(cString: av_get_media_type_string(native)) ?? "unknown"
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
