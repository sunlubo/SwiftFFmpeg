//
//  device_list.swift
//  SwiftFFmpegExamples
//
//  Created by sunlubo on 2019/1/18.
//

import SwiftFFmpeg

func device_list() throws {
    print(Device.configuration)
    print(Device.supportedAudioInputDevices)
    print(Device.supportedVideoInputDevices)
    print(Device.supportedAudioOutputDevices)
    print(Device.supportedVideoOutputDevices)
    
    let fmtCtx = try FormatContext(format: nil, formatName: "opengl")
    let capabilities = try DeviceCapabilitiesQuery(formatContext: fmtCtx)
    print(capabilities)
    
    for fmt in InputFormat.supportedFormats
        where fmt.privClass?.category == .deviceAudioInput ||
        fmt.privClass?.category == .deviceVideoInput ||
        fmt.privClass?.category == .deviceInput {
        print(fmt)
    }
    
    for fmt in OutputFormat.supportedFormats
        where fmt.privClass?.category == .deviceAudioOutput ||
        fmt.privClass?.category == .deviceVideoOutput ||
        fmt.privClass?.category == .deviceOutput {
        print(fmt)
    }
    
    let input = try DeviceInfoList.listInputSources(device: nil, deviceName: "videotoolbox")
    print(input)
}
