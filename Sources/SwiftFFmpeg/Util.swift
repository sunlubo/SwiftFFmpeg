//
//  Util.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/9.
//

import CFFmpeg

internal func dumpUnrecognizedOptions(_ dict: OpaquePointer?) {
    var tag: UnsafeMutablePointer<AVDictionaryEntry>?
    while let next = av_dict_get(dict, "", tag, AV_DICT_IGNORE_SUFFIX) {
        print("Warning: Option `\(String(cString: next.pointee.key))` not recognized.")
        tag = next
    }
}
