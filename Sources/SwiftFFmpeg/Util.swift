//
//  Util.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/9.
//

import CFFmpeg

/// Allows to "box" another value.
final class Box<T> {
    let value: T

    init(_ value: T) {
        self.value = value
    }
}

func dumpUnrecognizedOptions(_ dict: OpaquePointer?) {
    var prev: UnsafeMutablePointer<AVDictionaryEntry>?
    while let tag = av_dict_get(dict, "", prev, AV_DICT_IGNORE_SUFFIX) {
        AVLog.log(level: .warning, message: "Option '\(String(cString: tag.pointee.key!))' not found.")
        prev = tag
    }
}

func values<T>(_ ptr: UnsafePointer<T>?, until end: T) -> [T]? where T: Equatable {
    values(ptr, until: { $0 == end })
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
