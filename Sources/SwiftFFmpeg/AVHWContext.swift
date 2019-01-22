//
//  AVHWContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/6.
//

import CFFmpeg

// MARK: - AVHWDeviceType

public typealias AVHWDeviceType = CFFmpeg.AVHWDeviceType

extension AVHWDeviceType {
    /// Do not use any hardware acceleration (the default).
    public static let none = AV_HWDEVICE_TYPE_NONE
    /// Use VDPAU (Video Decode and Presentation API for Unix) hardware acceleration.
    public static let vdpau = AV_HWDEVICE_TYPE_VDPAU
    public static let cuda = AV_HWDEVICE_TYPE_CUDA
    /// Use DXVA2 (DirectX Video Acceleration) hardware acceleration.
    public static let dxva2 = AV_HWDEVICE_TYPE_DXVA2
    public static let qsv = AV_HWDEVICE_TYPE_QSV
    public static let videoToolbox = AV_HWDEVICE_TYPE_VIDEOTOOLBOX
    public static let d3d11va = AV_HWDEVICE_TYPE_D3D11VA
    public static let drm = AV_HWDEVICE_TYPE_DRM
    public static let openCL = AV_HWDEVICE_TYPE_OPENCL
    public static let mediaCodec = AV_HWDEVICE_TYPE_MEDIACODEC

    /// Look up an `AVHWDeviceType` by name.
    ///
    /// - Parameter name: String name of the device type (case-insensitive).
    /// - Returns: The requested device type, or `nil` if not found.
    public init?(name: String) {
        let type = av_hwdevice_find_type_by_name(name)
        if type == .none {
            return nil
        }
        self = type
    }

    /// Get the string name of an `AVHWDeviceType`.
    public var name: String {
        return String(cString: av_hwdevice_get_type_name(self)) ?? "unknown"
    }

    /// Get all supported device types.
    public static func supportedDeviceTypes() -> [AVHWDeviceType] {
        var list = [AVHWDeviceType]()
        var type = av_hwdevice_iterate_types(.none)
        while type != .none {
            list.append(type)
            type = av_hwdevice_iterate_types(type)
        }
        return list
    }
}

extension AVHWDeviceType: CustomStringConvertible {

    public var description: String {
        return name
    }
}

// MARK: - AVCodecHWConfig

typealias CAVCodecHWConfig = CFFmpeg.AVCodecHWConfig

public final class AVCodecHWConfig {
    let cConfigPtr: UnsafePointer<CAVCodecHWConfig>
    var cConfig: CAVCodecHWConfig { return cConfigPtr.pointee }

    init(cConfigPtr: UnsafePointer<CAVCodecHWConfig>) {
        self.cConfigPtr = cConfigPtr
    }

    /// A hardware pixel format which the codec can use.
    public var pixelFormat: AVPixelFormat {
        return cConfig.pix_fmt
    }

    /// Bit set of `AVCodecHWConfig.Method` flags, describing the possible setup methods
    /// which can be used with this configuration.
    public var methods: Method {
        return Method(rawValue: cConfig.methods)
    }

    /// The device type associated with the configuration.
    ///
    /// Must be set for `AVCodecHWConfigMethod.hwDeviceContext` and `AVCodecHWConfigMethod.hwFramesContext`,
    /// otherwise unused.
    public var deviceType: AVHWDeviceType {
        return cConfig.device_type
    }
}

// MARK: - AVCodecHWConfig.Method

extension AVCodecHWConfig {

    /// Flags used by `AVCodecHWConfig.methods`.
    public struct Method: OptionSet {
        /// The codec supports this format via the `AVCodecContext.hwDeviceContext` interface.
        ///
        /// When selecting this format, `AVCodecContext.hwDeviceContext` should
        /// have been set to a device of the specified type before calling
        /// `AVCodecContext.openCodec(options:)`.
        public static let hwDeviceContext = Method(rawValue: Int32(AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX))

        /// The codec supports this format via the `hw_frames_ctx` interface.
        ///
        /// When selecting this format for a decoder, `AVCodecContext.hw_frames_ctx`
        /// should be set to a suitable frames context inside the `get_format()` callback.
        /// The frames context must have been created on a device of the specified type.
        public static let hwFramesContext = Method(rawValue: Int32(AV_CODEC_HW_CONFIG_METHOD_HW_FRAMES_CTX))

        /// The codec supports this format by some internal method.
        ///
        /// This format can be selected without any additional configuration -
        /// no device or frames context is required.
        public static let `internal` = Method(rawValue: Int32(AV_CODEC_HW_CONFIG_METHOD_INTERNAL))

        /// The codec supports this format by some ad-hoc method.
        ///
        /// Additional settings and/or function calls are required. See the codec-specific
        /// documentation for details. (Methods requiring this sort of configuration are
        /// deprecated and others should be used in preference.)
        public static let adHoc = Method(rawValue: Int32(AV_CODEC_HW_CONFIG_METHOD_AD_HOC))

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension AVCodecHWConfig.Method: CustomStringConvertible {

    public var description: String {
        var str = "["
        if contains(.hwDeviceContext) { str += "hwDeviceContext, " }
        if contains(.hwFramesContext) { str += "hwFramesContext, " }
        if contains(.internal) { str += "`internal`, " }
        if contains(.adHoc) { str += "adHoc, " }
        if str.suffix(2) == ", " {
            str.removeLast(2)
        }
        str += "]"
        return str
    }
}

// MARK: - AVHWDeviceContext

public final class AVHWDeviceContext {
    let cContextPtr: UnsafeMutablePointer<CAVBuffer>

    init(cContextPtr: UnsafeMutablePointer<CAVBuffer>) {
        self.cContextPtr = cContextPtr
    }

    /// Open a device of the specified type and create an `AVHWDeviceContext` for it.
    ///
    /// The returned context is already initialized and ready for use, the caller
    /// should not call `av_hwdevice_ctx_init()` on it. The user_opaque/free fields of
    /// the created `AVHWDeviceContext` are set by this function and should not be
    /// touched by the caller.
    ///
    /// - Parameters:
    ///   - deviceType: The type of the device to create.
    ///   - device: A type-specific string identifying the device to open.
    ///   - options: A dictionary of additional (type-specific) options to use in opening the device.
    public init(
        deviceType: AVHWDeviceType,
        device: String? = nil,
        options: [String: String]? = nil
    ) throws {
        var pm: OpaquePointer? = options?.toAVDict()
        defer { av_dict_free(&pm) }
        var ctxPtr: UnsafeMutablePointer<AVBufferRef>?
        let ret = av_hwdevice_ctx_create(&ctxPtr, deviceType, device, pm, 0)
        try throwIfFail(ret)
        self.cContextPtr = ctxPtr!
    }

    deinit {
        var ptr: UnsafeMutablePointer<AVBufferRef>? = cContextPtr
        av_buffer_unref(&ptr)
    }
}

extension AVFrame {

    /// Copy data to or from a hw surface. At least one of `dst`/`src` must have an
    /// `AVHWFramesContext` attached.
    ///
    /// If `src` has an `AVHWFramesContext` attached, then the format of `dst` (if set)
    /// must use one of the formats returned by `av_hwframe_transfer_get_formats(src,
    /// AV_HWFRAME_TRANSFER_DIRECTION_FROM)`.
    /// If `dst` has an `AVHWFramesContext` attached, then the format of `src` must use one
    /// of the formats returned by `av_hwframe_transfer_get_formats(dst,
    /// AV_HWFRAME_TRANSFER_DIRECTION_TO)`.
    ///
    /// `dst` may be "clean" (i.e. with data/buf pointers unset), in which case the
    /// data buffers will be allocated by this function using `av_frame_get_buffer()`.
    /// If `dst->format` is set, then this format will be used, otherwise (when
    /// `dst->format` is `AVPixelFormat.none`) the first acceptable format will be chosen.
    ///
    /// The two frames must have matching allocated dimensions (i.e. equal to
    /// `AVHWFramesContext.width/height`), since not all device types support
    /// transferring a sub-rectangle of the whole surface. The display dimensions
    /// (i.e. `AVFrame.width/height`) may be smaller than the allocated dimensions, but
    /// also have to be equal for both frames. When the display dimensions are
    /// smaller than the allocated dimensions, the content of the padding in the
    /// destination frame is unspecified.
    ///
    /// - Parameter frame: the source frame
    /// - Throws: AVError
    public func transferData(from frame: AVFrame) throws {
        try throwIfFail(av_hwframe_transfer_data(cFramePtr, frame.cFramePtr, 0))
    }
}
