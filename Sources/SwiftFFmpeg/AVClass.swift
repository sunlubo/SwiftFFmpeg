//
//  AVClass.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/24.
//

import CFFmpeg

// MARK: - AVClassCategory

public typealias AVClassCategory = CFFmpeg.AVClassCategory

extension AVClassCategory {
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
}

extension AVClassCategory: CustomStringConvertible {

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

// MARK: - AVClass

typealias CAVClass = CFFmpeg.AVClass

public struct AVClass {
    /// The name of the class.
    public let name: String
    /// The options of the class.
    public let options: [AVOption]?
    /// The category of the class. It's used for visualization (like color).
    ///
    /// This is only set if the category is equal for all objects using this class.
    public let category: AVClassCategory

    init(cClassPtr: UnsafePointer<CAVClass>) {
        self.name = String(cString: cClassPtr.pointee.class_name)
        self.category = cClassPtr.pointee.category
        self.options = values(cClassPtr.pointee.option, until: { $0.name == nil })?.map(AVOption.init(cOption:))
    }
}

// MARK: - AVClassSupport

public protocol AVClassSupport {
    static var `class`: AVClass { get }

    func withUnsafeClassObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T
}
