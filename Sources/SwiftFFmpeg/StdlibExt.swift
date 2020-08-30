//
//  StdlibExt.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/12/30.
//

import CFFmpeg

extension UnsafePointer {

  var mutable: UnsafeMutablePointer<Pointee> {
    UnsafeMutablePointer(mutating: self)
  }
}

extension UnsafeBufferPointer {

  var mutable: UnsafeMutableBufferPointer<Element> {
    UnsafeMutableBufferPointer(mutating: self)
  }
}

extension UnsafeBufferPointer where Element == UInt8 {

  public var md5: String {
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
    defer {
      buffer.deinitialize(count: 16)
    }
    buffer.initialize(repeating: 0, count: 16)
    av_md5_sum(buffer, baseAddress, Int32(count))
    return (0..<16).reduce("") { result, index in
      let hex = String(buffer[index], radix: 16, uppercase: true)
      return result + (hex.count > 1 ? hex : ("0" + hex))
    }
  }
}

extension String {

  init?(cString: UnsafePointer<CChar>?) {
    guard let cString = cString else {
      return nil
    }
    self.init(cString: cString)
  }
}

extension Dictionary where Key == String, Value == String {
  var avDict: OpaquePointer? {
    var pm: OpaquePointer?
    for (k, v) in self {
      av_dict_set(&pm, k, v, 0)
    }
    return pm
  }
}
