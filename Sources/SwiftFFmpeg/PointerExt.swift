//
//  PointerExt.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/9/1.
//

extension UnsafePointer {

    var mutable: UnsafeMutablePointer<Pointee> {
        return UnsafeMutablePointer(mutating: self)
    }
}
