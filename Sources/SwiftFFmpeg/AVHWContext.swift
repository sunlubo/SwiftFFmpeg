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

public struct AVCodecHWConfig {
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
    let cBufferPtr: UnsafeMutablePointer<CAVBuffer>

    private var freeWhenDone: Bool = false

    init(cBufferPtr: UnsafeMutablePointer<CAVBuffer>) {
        self.cBufferPtr = cBufferPtr
    }

    /// Open a device of the specified type and create an `AVHWDeviceContext` for it.
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

        var ptr: UnsafeMutablePointer<AVBufferRef>!
        try throwIfFail(av_hwdevice_ctx_create(&ptr, deviceType, device, pm, 0))
        self.cBufferPtr = ptr
        self.freeWhenDone = true
    }

    /// Create a new device of the specified type from an existing device.
    ///
    /// If the source device is a device of the target type or was originally
    /// derived from such a device (possibly through one or more intermediate
    /// devices of other types), then this will return a reference to the
    /// existing device of the same type as is requested.
    ///
    /// Otherwise, it will attempt to derive a new device from the given source
    /// device. If direct derivation to the new type is not implemented, it will
    /// attempt the same derivation from each ancestor of the source device in
    /// turn looking for an implemented derivation method.
    ///
    /// - Parameters:
    ///   - deviceType: The type of the new device to create.
    ///   - deviceContext: An existing `AVHWDeviceContext` which will be used to create the new device.
    /// - Throws: AVError
    public init(deviceType: AVHWDeviceType, deviceContext: AVHWDeviceContext) throws {
        var ptr: UnsafeMutablePointer<AVBufferRef>!
        try throwIfFail(av_hwdevice_ctx_create_derived(&ptr, deviceType, deviceContext.cBufferPtr, 0))
        self.cBufferPtr = ptr
        self.freeWhenDone = true
    }

    deinit {
        if freeWhenDone {
            var ptr: UnsafeMutablePointer<AVBufferRef>? = cBufferPtr
            av_buffer_unref(&ptr)
        }
    }
}

// MARK: - AVHWFramesContext

typealias CAVHWFramesContext = CFFmpeg.AVHWFramesContext

/// This struct describes a set or pool of "hardware" frames (i.e. those with
/// data not located in normal system memory). All the frames in the pool are
/// assumed to be allocated in the same way and interchangeable.
///
/// This struct is reference-counted with the `AVBuffer` mechanism and tied to a
/// given `AVHWDeviceContext` instance. The `init(deviceContext:)` constructor
/// yields a reference, whose data field points to the actual `AVHWFramesContext`
/// struct.
public final class AVHWFramesContext {
    let cBufferPtr: UnsafeMutablePointer<CAVBuffer>
    let cContextPtr: UnsafeMutablePointer<CAVHWFramesContext>
    var cContext: CAVHWFramesContext { return cContextPtr.pointee }

    private var freeWhenDone: Bool = false

    init(cBufferPtr: UnsafeMutablePointer<CAVBuffer>) {
        self.cBufferPtr = cBufferPtr
        self.cContextPtr = UnsafeMutableRawPointer(cBufferPtr.pointee.data)!
            .bindMemory(to: CAVHWFramesContext.self, capacity: 1)
    }

    /// Create an `AVHWFramesContext` tied to a given device context.
    ///
    /// - Parameter deviceContext: a `AVHWDeviceContext` instance.
    public init(deviceContext: AVHWDeviceContext) {
        guard let ptr = av_hwframe_ctx_alloc(deviceContext.cBufferPtr) else {
            abort("av_hwframe_ctx_alloc")
        }
        self.cBufferPtr = ptr
        self.cContextPtr = UnsafeMutableRawPointer(ptr.pointee.data)!
            .bindMemory(to: CAVHWFramesContext.self, capacity: 1)
        self.freeWhenDone = true
    }

    /// A reference to the parent `AVHWDeviceContext`.
    public var deviceContext: AVHWDeviceContext {
        return AVHWDeviceContext(cBufferPtr: cContext.device_ref)
    }

    /// The pixel format identifying the underlying HW surface type.
    /// Must be a hwaccel format, i.e. the corresponding descriptor must have the
    /// `AV_PIX_FMT_FLAG_HWACCEL` flag set.
    ///
    /// Must be set by the user before calling `initialize()`.
    public var pixelFormat: AVPixelFormat {
        get { return cContext.format }
        set { cContextPtr.pointee.format = newValue }
    }

    /// The pixel format identifying the actual data layout of the hardware
    /// frames.
    ///
    /// Must be set by the caller before calling `initialize()`.
    ///
    /// - Note: When the underlying API does not provide the exact data layout, but
    /// only the colorspace/bit depth, this field should be set to the fully
    /// planar version of that format (e.g. for 8-bit 420 YUV it should be
    /// `AVPixelFormat.YUV420P`, not `AVPixelFormat.NV12` or anything else).
    public var swPixelFormat: AVPixelFormat {
        get { return cContext.sw_format }
        set { cContextPtr.pointee.sw_format = newValue }
    }

    /// The width of the frames in this pool.
    ///
    /// Must be set by the user before calling `initialize()`.
    public var width: Int {
        get { return Int(cContext.width) }
        set { cContextPtr.pointee.width = Int32(newValue) }
    }

    /// The height of the frames in this pool.
    ///
    /// Must be set by the user before calling `initialize()`.
    public var height: Int {
        get { return Int(cContext.height) }
        set { cContextPtr.pointee.height = Int32(newValue) }
    }

    /// Initial size of the frame pool. If a device type does not support
    /// dynamically resizing the pool, then this is also the maximum pool size.
    ///
    /// May be set by the caller before calling `initialize()`.
    /// Must be set if pool is `nil` and the device type does not support dynamic pools.
    public var initialPoolSize: Int {
        get { return Int(cContext.initial_pool_size) }
        set { cContextPtr.pointee.initial_pool_size = Int32(newValue) }
    }

    /// Finalize the context before use. This function must be called after the
    /// context is filled with all the required information and before it is attached
    /// to any frames.
    ///
    /// - Throws: AVError
    public func initialize() throws {
        try throwIfFail(av_hwframe_ctx_init(cBufferPtr))
    }

    /// Allocate a new frame attached to the given `AVHWFramesContext`.
    ///
    /// - Parameter frame: an empty (freshly allocated or unreffed) frame to be filled with
    ///   newly allocated buffers.
    /// - Throws: AVError
    public func allocBuffer(frame: AVFrame) throws {
        try throwIfFail(av_hwframe_get_buffer(cBufferPtr, frame.cFramePtr, 0))
    }

    deinit {
        if freeWhenDone {
            var ptr: UnsafeMutablePointer<AVBufferRef>? = cBufferPtr
            av_buffer_unref(&ptr)
        }
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
