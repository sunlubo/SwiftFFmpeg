//
//  avio_reading.swift
//  SwiftFFmpegExamples
//
//  Created by sunlubo on 2019/1/9.
//

import Foundation
import SwiftFFmpeg

private struct BufferData {
    var ptr: UnsafeMutablePointer<UInt8>
    var size: Int
}

private func read_packet(opaque: UnsafeMutableRawPointer?, buffer: UnsafeMutablePointer<UInt8>?, size: Int) -> Int {
    let bdPtr = opaque!.bindMemory(to: BufferData.self, capacity: 1)
    let bufSize = min(size, bdPtr.pointee.size)
    if bufSize == 0 {
        return Int(AVError.eof.code)
    }

    print("ptr: 0x\(String(Int(bitPattern: bdPtr.pointee.ptr), radix: 16, uppercase: false))  size: \(bdPtr.pointee.size)")

    // copy internal buffer data to buf
    buffer!.assign(from: bdPtr.pointee.ptr, count: bufSize)
    bdPtr.pointee.ptr = bdPtr.pointee.ptr.advanced(by: bufSize)
    bdPtr.pointee.size = bdPtr.pointee.size - bufSize

    return bufSize
}

func avio_reading() throws {
    if CommandLine.argc < 3 {
        print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input_file")
        return
    }

    let input = CommandLine.arguments[2]
    let bufferSize = 4096

    // slurp file content into buffer
    var fileBuffer: UnsafeMutablePointer<UInt8>!
    var size = 0
    try AVIO.fileMap(filename: input, buffer: &fileBuffer, size: &size)
    defer {
        AVIO.fileUnmap(buffer: fileBuffer, size: size)
    }
    // fill opaque structure used by the IOContext read callback
    var bufferData = BufferData(ptr: fileBuffer, size: size)

    let ioCtxBuffer = AVIO.malloc(size: bufferSize)!.bindMemory(to: UInt8.self, capacity: bufferSize)
    let ioCtx = IOContext(
        buffer: ioCtxBuffer,
        size: bufferSize,
        writable: false,
        opaque: &bufferData,
        readHandler: read_packet,
        writeHandler: nil,
        seekHandler: nil
    )

    let fmtCtx = FormatContext()
    fmtCtx.pb = ioCtx
    try fmtCtx.openInput()
    try fmtCtx.findStreamInfo()
    fmtCtx.dumpFormat(url: input, isOutput: false)
}
