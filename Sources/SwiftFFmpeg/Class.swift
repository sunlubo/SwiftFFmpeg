//
//  Class.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/24.
//

import CFFmpeg

// MARK: - Class

typealias CAVClass = CFFmpeg.AVClass

public struct Class {
    /// The name of the class.
    public let name: String
    /// The options of the class.
    public let options: [Option]?
    /// The category of the class. It's used for visualization (like color).
    ///
    /// This is only set if the category is equal for all objects using this class.
    public let category: Category

    init(cClassPtr: UnsafePointer<CAVClass>) {
        self.name = String(cString: cClassPtr.pointee.class_name)
        self.category = Category(rawValue: cClassPtr.pointee.category.rawValue)!
        self.options = values(cClassPtr.pointee.option, until: { $0.name == nil })?.map(Option.init(cOption:))
    }
}

// MARK: - Class.Category

extension Class {

    // https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/log.h#L48
    public enum Category: UInt32 {
        case na = 0
        case input
        case output
        case muxer
        case demuxer
        case encoder
        case decoder
        case filter
        case bitStreamFilter
        case swscaler
        case swresampler
        case deviceVideoOutput = 40
        case deviceVideoInput
        case deviceAudioOutput
        case deviceAudioInput
        case deviceOutput
        case deviceInput

        public var isInputDevice: Bool {
            self == .deviceVideoInput
                || self == .deviceAudioInput
                || self == .deviceInput
        }

        public var isOutputDevice: Bool {
            self == .deviceVideoOutput
                || self == .deviceAudioOutput
                || self == .deviceOutput
        }
    }
}

extension Class.Category: CustomStringConvertible {

    public var description: String {
        switch self {
        case .na:
            return "na"
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
        }
    }
}

// MARK: - ClassSupport

public protocol ClassSupport {
    static var `class`: Class { get }

    func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T
}
