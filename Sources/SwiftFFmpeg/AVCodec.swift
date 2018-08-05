//
//  Codec.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/28.
//

import CFFmpeg

// MARK: - AVCodecID

public typealias AVCodecID = CFFmpeg.AVCodecID

extension AVCodecID {
    public static let NONE = AV_CODEC_ID_NONE

    // MARK: - Video Codecs

    public static let MPEG1VIDEO = AV_CODEC_ID_MPEG1VIDEO
    /// preferred ID for MPEG-1/2 video decoding
    public static let MPEG2VIDEO = AV_CODEC_ID_MPEG2VIDEO
    public static let H261 = AV_CODEC_ID_H261
    public static let H263 = AV_CODEC_ID_H263
    public static let MPEG4 = AV_CODEC_ID_MPEG4
    public static let H264 = AV_CODEC_ID_H264
    public static let VP3 = AV_CODEC_ID_VP3
    public static let PNG = AV_CODEC_ID_PNG
    public static let PGM = AV_CODEC_ID_PGM
    public static let BMP = AV_CODEC_ID_BMP
    public static let JPEG2000 = AV_CODEC_ID_JPEG2000
    public static let VP5 = AV_CODEC_ID_VP5
    public static let VP6 = AV_CODEC_ID_VP6
    public static let TIFF = AV_CODEC_ID_TIFF
    public static let GIF = AV_CODEC_ID_GIF
    public static let VP8 = AV_CODEC_ID_VP8
    public static let VP9 = AV_CODEC_ID_VP9
    public static let WEBP = AV_CODEC_ID_WEBP
    public static let HEVC = AV_CODEC_ID_HEVC
    public static let VP7 = AV_CODEC_ID_VP7
    public static let APNG = AV_CODEC_ID_APNG
    public static let AV1 = AV_CODEC_ID_AV1
    public static let SVG = AV_CODEC_ID_SVG

    // MARK: - various PCM "codecs"

    /// A dummy id pointing at the start of audio codecs
    public static let FIRST_AUDIO = AV_CODEC_ID_FIRST_AUDIO
    public static let PCM_S16LE = AV_CODEC_ID_PCM_S16LE
    public static let PCM_S16BE = AV_CODEC_ID_PCM_S16BE
    public static let PCM_U16LE = AV_CODEC_ID_PCM_U16LE
    public static let PCM_U16BE = AV_CODEC_ID_PCM_U16BE
    public static let PCM_S8 = AV_CODEC_ID_PCM_S8
    public static let PCM_U8 = AV_CODEC_ID_PCM_U8
    public static let PCM_MULAW = AV_CODEC_ID_PCM_MULAW
    public static let PCM_ALAW = AV_CODEC_ID_PCM_ALAW
    public static let PCM_S32LE = AV_CODEC_ID_PCM_S32LE
    public static let PCM_S32BE = AV_CODEC_ID_PCM_S32BE
    public static let PCM_U32LE = AV_CODEC_ID_PCM_U32LE
    public static let PCM_U32BE = AV_CODEC_ID_PCM_U32BE
    public static let PCM_S24LE = AV_CODEC_ID_PCM_S24LE
    public static let PCM_S24BE = AV_CODEC_ID_PCM_S24BE
    public static let PCM_U24LE = AV_CODEC_ID_PCM_U24LE
    public static let PCM_U24BE = AV_CODEC_ID_PCM_U24BE
    public static let PCM_S24DAUD = AV_CODEC_ID_PCM_S24DAUD
    public static let PCM_ZORK = AV_CODEC_ID_PCM_ZORK
    public static let PCM_S16LE_PLANAR = AV_CODEC_ID_PCM_S16LE_PLANAR
    public static let PCM_DVD = AV_CODEC_ID_PCM_DVD
    public static let PCM_F32BE = AV_CODEC_ID_PCM_F32BE
    public static let PCM_F32LE = AV_CODEC_ID_PCM_F32LE
    public static let PCM_F64BE = AV_CODEC_ID_PCM_F64BE
    public static let PCM_F64LE = AV_CODEC_ID_PCM_F64LE
    public static let PCM_BLURAY = AV_CODEC_ID_PCM_BLURAY
    public static let PCM_LXF = AV_CODEC_ID_PCM_LXF
    public static let S302M = AV_CODEC_ID_S302M
    public static let PCM_S8_PLANAR = AV_CODEC_ID_PCM_S8_PLANAR
    public static let PCM_S24LE_PLANAR = AV_CODEC_ID_PCM_S24LE_PLANAR
    public static let PCM_S32LE_PLANAR = AV_CODEC_ID_PCM_S32LE_PLANAR
    public static let PCM_S16BE_PLANAR = AV_CODEC_ID_PCM_S16BE_PLANAR

    public static let PCM_S64LE = AV_CODEC_ID_PCM_S64LE
    public static let PCM_S64BE = AV_CODEC_ID_PCM_S64BE
    public static let PCM_F16LE = AV_CODEC_ID_PCM_F16LE
    public static let PCM_F24LE = AV_CODEC_ID_PCM_F24LE

    // MARK: - AMR

    public static let AMR_NB = AV_CODEC_ID_AMR_NB
    public static let AMR_WB = AV_CODEC_ID_AMR_WB

    // MARK: - Audio Codecs

    public static let MP2 = AV_CODEC_ID_MP2
    /// preferred ID for decoding MPEG audio layer 1, 2 or 3
    public static let MP3 = AV_CODEC_ID_MP3
    public static let AAC = AV_CODEC_ID_AAC
    public static let FLAC = AV_CODEC_ID_FLAC
    public static let APE = AV_CODEC_ID_APE
    public static let MP1 = AV_CODEC_ID_MP1

    /// The codec's name.
    public var name: String {
        return String(cString: avcodec_get_name(self))
    }

    /// The codec's media type.
    public var mediaType: AVMediaType {
        return avcodec_get_type(self)
    }
}

// MARK: - AVCodecCap

/// codec capabilities
public struct AVCodecCap: OptionSet {
    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    /// Audio encoder supports receiving a different number of samples in each call.
    public static let variableFrameSize = AVCodecCap(rawValue: AV_CODEC_CAP_VARIABLE_FRAME_SIZE)
}

// MARK: - AVCodec

internal typealias CAVCodec = CFFmpeg.AVCodec

public struct AVCodec {
    internal let codecPtr: UnsafeMutablePointer<CAVCodec>
    internal var codec: CAVCodec { return codecPtr.pointee }

    /// Find a registered decoder with a matching codec ID.
    ///
    /// - Parameter codecId: id of the requested decoder
    /// - Returns: A decoder if one was found, `nil` otherwise.
    public static func findDecoderById(_ codecId: AVCodecID) -> AVCodec? {
        guard let codecPtr = avcodec_find_decoder(codecId) else {
            return nil
        }
        return AVCodec(codecPtr: codecPtr)
    }

    /// Find a registered decoder with the specified name.
    ///
    /// - Parameter name: name of the requested decoder
    /// - Returns: A decoder if one was found, `nil` otherwise.
    public static func findDecoderByName(_ name: String) -> AVCodec? {
        guard let codecPtr = avcodec_find_decoder_by_name(name) else {
            return nil
        }
        return AVCodec(codecPtr: codecPtr)
    }

    /// Find a registered encoder with a matching codec ID.
    ///
    /// - Parameter codecId: id of the requested encoder
    /// - Returns: An encoder if one was found, `nil` otherwise.
    public static func findEncoderById(_ codecId: AVCodecID) -> AVCodec? {
        guard let codecPtr = avcodec_find_encoder(codecId) else {
            return nil
        }
        return AVCodec(codecPtr: codecPtr)
    }

    /// Find a registered encoder with the specified name.
    ///
    /// - Parameter name: name of the requested encoder
    /// - Returns: An encoder if one was found, `nil` otherwise.
    public static func findEncoderByName(_ name: String) -> AVCodec? {
        guard let codecPtr = avcodec_find_encoder_by_name(name) else {
            return nil
        }
        return AVCodec(codecPtr: codecPtr)
    }

    internal init(codecPtr: UnsafeMutablePointer<CAVCodec>) {
        self.codecPtr = codecPtr
    }

    /// The codec's name.
    public var name: String {
        return String(cString: codec.name)
    }

    /// The codec's descriptive name, meant to be more human readable than name.
    public var longName: String {
        return String(cString: codec.long_name)
    }

    /// The codec's media type.
    public var mediaType: AVMediaType {
        return codec.type
    }

    /// The codec's id.
    public var id: AVCodecID {
        return codec.id
    }

    /// Codec capabilities.
    public var capabilities: AVCodecCap {
        return AVCodecCap(rawValue: codec.capabilities)
    }

    /// Returns an array of the framerates supported by the codec.
    public var supportedFramerates: [AVRational] {
        var list = [AVRational]()
        var ptr = codec.supported_framerates
        while let p = ptr, p.pointee != .zero {
            list.append(p.pointee)
            ptr = p.advanced(by: 1)
        }
        return list
    }

    /// Returns an array of the pixel formats supported by the codec.
    public var pixFmts: [AVPixelFormat] {
        var list = [AVPixelFormat]()
        var ptr = codec.pix_fmts
        while let p = ptr, p.pointee != .none {
            list.append(p.pointee)
            ptr = p.advanced(by: 1)
        }
        return list
    }

    /// Returns an array of the audio samplerates supported by the codec.
    public var supportedSampleRates: [Int] {
        var list = [Int]()
        var ptr = codec.supported_samplerates
        while let p = ptr, p.pointee != 0 {
            list.append(Int(p.pointee))
            ptr = p.advanced(by: 1)
        }
        return list
    }

    /// Returns an array of the sample formats supported by the codec.
    public var sampleFmts: [AVSampleFormat] {
        var list = [AVSampleFormat]()
        var ptr = codec.sample_fmts
        while let p = ptr, p.pointee != .none {
            list.append(p.pointee)
            ptr = p.advanced(by: 1)
        }
        return list
    }

    /// Returns an array of the channel layouts supported by the codec.
    public var channelLayouts: [AVChannelLayout] {
        var list = [AVChannelLayout]()
        var ptr = codec.channel_layouts
        while let p = ptr, p.pointee != 0 {
            list.append(AVChannelLayout(rawValue: p.pointee))
            ptr = p.advanced(by: 1)
        }
        return list
    }

    /// Maximum value for lowres supported by the decoder.
    public var maxLowres: UInt8 {
        return codec.max_lowres
    }

    /// Returns a Boolean value indicating whether the codec is decoder.
    public var isDecoder: Bool {
        return av_codec_is_decoder(codecPtr) != 0
    }

    /// Returns a Boolean value indicating whether the codec is encoder.
    public var isEncoder: Bool {
        return av_codec_is_encoder(codecPtr) != 0
    }
}
