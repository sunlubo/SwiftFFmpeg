//
//  Util.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/9.
//

import CFFmpeg

/// Do global initialization of network libraries. This is optional, and not recommended anymore.
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
public func networkInit() -> Int32 {
    return avformat_network_init()
}

/// Undo the initialization done by `networkInit`. Call it only once for each time you called `networkInit`.
public func networkDeinit() -> Int32 {
    return avformat_network_deinit()
}

func dumpUnrecognizedOptions(_ dict: OpaquePointer?) {
    var tag: UnsafeMutablePointer<AVDictionaryEntry>?
    while let next = av_dict_get(dict, "", tag, AV_DICT_IGNORE_SUFFIX) {
        print("Warning: Option `\(String(cString: next.pointee.key!))` not recognized.")
        tag = next
    }
}

func values<T>(_ ptr: UnsafePointer<T>?, until end: T) -> [T]? where T: Equatable {
    return values(ptr, until: { $0 == end })
}

func values<T>(_ ptr: UnsafePointer<T>?, until predicate: (T) -> Bool) -> [T]? {
    guard let start = ptr else { return nil }

    var end = start
    while !predicate(end.pointee) {
        end = end.advanced(by: 1)
    }
    guard end > start else { return [] }
    return Array(UnsafeBufferPointer(start: start, count: end - start))
}
