//
//  device_list.swift
//  SwiftFFmpegExamples
//
//  Created by sunlubo on 2019/1/18.
//

import SwiftFFmpeg

func device_list() throws {
    print(AVDevice.configuration)
    print(AVDevice.supportedAudioInputDevices)
    print(AVDevice.supportedVideoInputDevices)
    print(AVDevice.supportedAudioOutputDevices)
    print(AVDevice.supportedVideoOutputDevices)
    
    let fmtCtx = try AVFormatContext(format: nil, formatName: "opengl")
    let capabilities = try AVDeviceCapabilitiesQuery(formatContext: fmtCtx)
    print(capabilities)
    
    for fmt in AVInputFormat.supportedFormats
        where fmt.privClass?.category == AVClassCategory.deviceAudioInput ||
        fmt.privClass?.category == AVClassCategory.deviceVideoInput ||
        fmt.privClass?.category == AVClassCategory.deviceInput {
        print(fmt)
    }
    
    for fmt in AVOutputFormat.supportedFormats
        where fmt.privClass?.category == AVClassCategory.deviceAudioOutput ||
        fmt.privClass?.category == AVClassCategory.deviceVideoOutput ||
        fmt.privClass?.category == AVClassCategory.deviceOutput {
        print(fmt)
    }
    
    let input = try AVDeviceInfoList.listInputSources(device: nil, deviceName: "videotoolbox")
    print(input)
}
