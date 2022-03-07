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

  for fmt in AVInputFormat.supportedFormats where fmt.privClass?.category == .deviceAudioInput
    || fmt.privClass?.category == .deviceVideoInput
    || fmt.privClass?.category == .deviceInput {
    print(fmt)
  }

  for fmt in AVOutputFormat.supportedFormats where fmt.privClass?.category == .deviceAudioOutput
    || fmt.privClass?.category == .deviceVideoOutput
    || fmt.privClass?.category == .deviceOutput {
    print(fmt)
  }

  let input = try AVDeviceInfoList.listInputSources(device: nil, deviceName: "videotoolbox")
  print(input)
}
