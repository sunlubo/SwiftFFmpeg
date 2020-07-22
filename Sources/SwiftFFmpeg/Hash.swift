//
//  Hash.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/17.
//

import CFFmpeg

public final class AVHash {

  /// Hash an array of data.
  public static func calculateMD5(for bytes: UnsafeBufferPointer<UInt8>) -> UnsafePointer<UInt8> {
    let dst = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
    dst.initialize(to: 0)
    av_md5_sum(dst, bytes.baseAddress, Int32(bytes.count))
    return UnsafePointer(dst)
  }
}
