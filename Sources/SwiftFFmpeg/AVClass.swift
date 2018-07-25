//
//  AVClass.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/24.
//

import CFFmpeg

public typealias AVClassCategory = CFFmpeg.AVClassCategory

extension AVClassCategory: CustomStringConvertible {
    public static let na = AV_CLASS_CATEGORY_NA
    public static let input = AV_CLASS_CATEGORY_INPUT
    public static let output = AV_CLASS_CATEGORY_OUTPUT
    public static let muxer = AV_CLASS_CATEGORY_MUXER
    public static let demuxer = AV_CLASS_CATEGORY_DEMUXER
    public static let encoder = AV_CLASS_CATEGORY_ENCODER
    public static let decoder = AV_CLASS_CATEGORY_DECODER
    public static let filter = AV_CLASS_CATEGORY_FILTER
    public static let bitStreamFilter = AV_CLASS_CATEGORY_BITSTREAM_FILTER
    public static let swscaler = AV_CLASS_CATEGORY_SWSCALER
    public static let swresampler = AV_CLASS_CATEGORY_SWRESAMPLER
    public static let deviceVideoOutput = AV_CLASS_CATEGORY_DEVICE_VIDEO_OUTPUT
    public static let deviceVideoInput = AV_CLASS_CATEGORY_DEVICE_VIDEO_INPUT
    public static let deviceAudioOutput = AV_CLASS_CATEGORY_DEVICE_AUDIO_OUTPUT
    public static let deviceAudioInput = AV_CLASS_CATEGORY_DEVICE_AUDIO_INPUT
    public static let deviceOutput = AV_CLASS_CATEGORY_DEVICE_OUTPUT
    public static let deviceInput = AV_CLASS_CATEGORY_DEVICE_INPUT
    public static let nb = AV_CLASS_CATEGORY_NB

    public var description: String {
        switch self {
        case .na:
            return "NA"
        case .input:
            return "input"
        case .output:
            return "output"
        case .muxer:
            return "muxer"
        case .demuxer:
            return "demuxer"
        case .encoder:
            return "encoder"
        case .decoder:
            return "decoder"
        case .filter:
            return "filter"
        case .bitStreamFilter:
            return "bitStreamFilter"
        case .swscaler:
            return "swscaler"
        case .swresampler:
            return "swresampler"
        case .deviceVideoOutput:
            return "deviceVideoOutput"
        case .deviceVideoInput:
            return "deviceVideoInput"
        case .deviceAudioOutput:
            return "deviceAudioOutput"
        case .deviceAudioInput:
            return "deviceAudioInput"
        case .deviceOutput:
            return "deviceOutput"
        case .deviceInput:
            return "deviceInput"
        case .nb:
            return "NB"
        default:
            return "unknown"
        }
    }
}

internal typealias CAVClass = CFFmpeg.AVClass

/// This structure stores compressed data.
///
/// It is typically exported by demuxers and then passed as input to decoders,
/// or received as output from encoders and then passed to muxers.
public final class AVClass {
    internal let clazzPtr: UnsafePointer<CAVClass>
    internal var clazz: CAVClass { return clazzPtr.pointee }

    internal init(clazzPtr: UnsafePointer<CAVClass>) {
        self.clazzPtr = clazzPtr
    }

    /// The name of the class.
    public var name: String {
        return String(cString: clazz.class_name)
    }

    /// Category used for visualization (like color) This is only set if the category is equal for all objects using this class.
    public var category: AVClassCategory {
        return clazz.category
    }
}

extension AVFormatContext {

    public var avClass: AVClass {
        return AVClass(clazzPtr: avformat_get_class())
    }
}

extension AVCodecContext {

    public var avClass: AVClass {
        return AVClass(clazzPtr: avcodec_get_class())
    }
}

extension AVFrame {

    public var avClass: AVClass {
        return AVClass(clazzPtr: avcodec_get_frame_class())
    }
}
