//
//  hw_decode.swift
//  SwiftFFmpegExamples
//
//  Created by sunlubo on 2019/1/14.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#else
import Glibc
#endif
import SwiftFFmpeg

private func decode_write(
    codecCtx: CodecContext,
    pkt: Packet?,
    hwPixFmt: PixelFormat,
    file: UnsafeMutablePointer<FILE>
) throws {
    try codecCtx.sendPacket(pkt)

    while true {
        let frame = Frame()
        let swFrame = Frame()
        var tmpFrame: Frame!

        do {
            try codecCtx.receiveFrame(frame)
        } catch let err as AVError where err == .tryAgain || err == .eof {
            break
        }

        if frame.pixelFormat == hwPixFmt {
            // retrieve data from GPU to CPU
            try swFrame.transferData(from: frame)
            tmpFrame = swFrame
        } else {
            tmpFrame = frame
        }

        let buffer = try Image.makePixelBuffer(from: tmpFrame)
        defer { buffer.deallocate() }
        fwrite(buffer.baseAddress, 1, buffer.count, file)

        frame.unref()
    }
}

func hw_decode() throws {
    if CommandLine.argc < 5 {
        print("Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) device_type input_file output_file")
        return
    }

    let deviceTypeName = CommandLine.arguments[2]
    let input = CommandLine.arguments[3]
    let output = CommandLine.arguments[4]

    guard let deviceType = HardwareDeviceType(name: deviceTypeName) else {
        print("Device type \(deviceTypeName) is not supported.")
        print(HardwareDeviceType.supportedDeviceTypes())
        fatalError()
    }

    // open the file to dump raw data
    guard let file = fopen(output, "w+") else {
        fatalError("Could not open \(output).")
    }
    defer { fclose(file) }

    let fmtCtx = try FormatContext(url: input)
    try fmtCtx.findStreamInfo()

    // find the video stream information
    let streamIndex = fmtCtx.findBestStream(type: .video)!
    let stream = fmtCtx.streams[streamIndex]

    let decoder = Codec.findDecoderById(stream.codecParameters.codecId)!
    var i = 0
    var hwPixFmt = PixelFormat.none
    while true {
        guard let config = decoder.hwConfig(at: i) else {
            fatalError("Decoder \(decoder.name) does not support device type \(deviceTypeName).")
        }
        if config.methods.contains(.hwDeviceContext) && config.deviceType == deviceType {
            hwPixFmt = config.pixelFormat
            break
        }
        i += 1
    }

    let decoderCtx = CodecContext(codec: decoder)
    decoderCtx.setParameters(stream.codecParameters)
    decoderCtx.getFormat = { ctx, fmts in
        print(fmts)
        if fmts.contains(hwPixFmt) {
            return hwPixFmt
        }
        print("Failed to get HW surface format.")
        return .none
    }

    let deviceCtx = try HardwareDeviceContext(deviceType: deviceType)
    decoderCtx.hwDeviceContext = deviceCtx

    try decoderCtx.openCodec()

    // open the file to dump raw data

    // actual decoding and dump the raw data
    let pkt = Packet()
    while let _ = try? fmtCtx.readFrame(into: pkt) {
        defer {
            pkt.unref()
        }

        if pkt.streamIndex == streamIndex {
            try decode_write(codecCtx: decoderCtx, pkt: pkt, hwPixFmt: hwPixFmt, file: file)
        }
    }

    // flush
    try decode_write(codecCtx: decoderCtx, pkt: nil, hwPixFmt: hwPixFmt, file: file)
}
