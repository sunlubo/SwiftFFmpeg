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

extension String {

    init?(cString: UnsafePointer<CChar>?) {
        guard let cString = cString else { return nil }
        self.init(cString: cString)
    }
}

extension Dictionary where Key == String, Value == String {

    func toAVDict() -> OpaquePointer? {
        var pm: OpaquePointer?
        for (k, v) in self {
            av_dict_set(&pm, k, v, 0)
        }
        return pm
    }
}
