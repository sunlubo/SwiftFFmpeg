//
//  Codec.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/28.
//

import CFFmpeg

public typealias AVCodecID = CFFmpeg.AVCodecID

extension AVCodecID {

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

    // MARK: - Audio Codecs

    public static let MP2 = AV_CODEC_ID_MP2
    /// preferred ID for decoding MPEG audio layer 1, 2 or 3
    public static let MP3 = AV_CODEC_ID_MP3
    public static let AAC = AV_CODEC_ID_AAC
    public static let FLAC = AV_CODEC_ID_FLAC
    public static let APE = AV_CODEC_ID_APE
    public static let MP1 = AV_CODEC_ID_MP1

    public var codecName: String {
        return String(cString: avcodec_get_name(self))
    }

    /// Get the type of the given codec.
    public var codecType: AVMediaType {
        return avcodec_get_type(self)
    }
}

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

    /// Name of the codec implementation.
    ///
    /// The name is globally unique among encoders and among decoders
    /// (but an encoder and a decoder can share the same name).
    public var name: String {
        return String(cString: codec.name)
    }

    /// Descriptive name for the codec, meant to be more human readable than name.
    public var longName: String {
        return String(cString: codec.long_name)
    }

    public var type: AVMediaType {
        return codec.type
    }

    public var id: AVCodecID {
        return codec.id
    }

    /// Codec capabilities.
    ///
    /// see `AVCodecCap`.
    public var capabilities: Int32 {
        return codec.capabilities
    }

    /// Supported framerates.
    public var supportedFramerates: [AVRational] {
        var list = [AVRational]()
        var ptr = codec.supported_framerates
        while let p = ptr, p.pointee != .zero {
            list.append(p.pointee)
            ptr = p.advanced(by: 1)
        }
        return list
    }

    /// Supported pixel formats.
    public var pixFmts: [AVPixelFormat] {
        var list = [AVPixelFormat]()
        var ptr = codec.pix_fmts
        while let p = ptr, p.pointee != .none {
            list.append(p.pointee)
            ptr = p.advanced(by: 1)
        }
        return list
    }

    /// Supported audio samplerates.
    public var supportedSamplerates: [Int32] {
        var list = [Int32]()
        var ptr = codec.supported_samplerates
        while let p = ptr, p.pointee != 0 {
            list.append(p.pointee)
            ptr = p.advanced(by: 1)
        }
        return list
    }

    /// Supported sample formats.
    public var sampleFmts: [AVSampleFormat] {
        var list = [AVSampleFormat]()
        var ptr = codec.sample_fmts
        while let p = ptr, p.pointee != .none {
            list.append(p.pointee)
            ptr = p.advanced(by: 1)
        }
        return list
    }

    /// Support channel layouts.
    public var channelLayouts: [UInt64] {
        var list = [UInt64]()
        var ptr = codec.channel_layouts
        while let p = ptr, p.pointee != 0 {
            list.append(p.pointee)
            ptr = p.advanced(by: 1)
        }
        return list
    }

    public var isDecoder: Bool {
        return av_codec_is_decoder(codecPtr) != 0
    }

    public var isEncoder: Bool {
        return av_codec_is_encoder(codecPtr) != 0
    }
}
