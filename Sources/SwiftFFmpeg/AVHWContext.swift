//
//  AVHWContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/6.
//

import CFFmpeg

// MARK: - AVHWDeviceType

public enum AVHWDeviceType: UInt32 {
  /// Do not use any hardware acceleration (the default).
  case none
  /// Use VDPAU (Video Decode and Presentation API for Unix) hardware acceleration.
  case vdpau
  /// Use CUDA (Compute Unified Device Architecture, NVIDIA) hardware acceleration.
  case cuda
  /// Use VA-API (Video Acceleration API) hardware acceleration.
  case vaapi
  /// Use DXVA2 (DirectX Video Acceleration) hardware acceleration.
  case dxva2
  /// Use QSV (Intel Quick Sync Video) hardware acceleration.
  case qsv
  /// Use VideoToolbox (Apple) hardware acceleration.
  case videoToolbox
  /// Use D3D11VA (Direct3D 11 Graphics) hardware acceleration.
  case d3d11va
  /// Use DRM (Direct Rendering Manage) hardware acceleration.
  case drm
  /// Use OpenCL hardware acceleration.
  case openCL
  /// Use MediaCodec (Android) hardware acceleration.
  case mediaCodec

  var native: CFFmpeg.AVHWDeviceType {
    CFFmpeg.AVHWDeviceType(rawValue)
  }

  init(native: CFFmpeg.AVHWDeviceType) {
    guard let type = AVHWDeviceType(rawValue: native.rawValue) else {
      fatalError("Unknown device type: \(native)")
    }
    self = type
  }

  /// Return an `AVHWDeviceType` corresponding to name, or `nil` if the device type does not exist.
  ///
  /// - Parameter name: String name of the device type (case-insensitive).
  public init?(name: String) {
    let type = av_hwdevice_find_type_by_name(name)
    guard type != AV_HWDEVICE_TYPE_NONE else {
      return nil
    }
    self = AVHWDeviceType(native: type)
  }

  /// The name of the device type.
  public var name: String? {
    String(cString: av_hwdevice_get_type_name(native))
  }

  /// Get all supported device types.
  public static func supportedDeviceTypes() -> [AVHWDeviceType] {
    var list = [AVHWDeviceType]()
    var type = av_hwdevice_iterate_types(AV_HWDEVICE_TYPE_NONE)
    while type != AV_HWDEVICE_TYPE_NONE {
      list.append(AVHWDeviceType(native: type))
      type = av_hwdevice_iterate_types(type)
    }
    return list
  }
}

// MARK: - AVHWDeviceType + CustomStringConvertible

extension AVHWDeviceType: CustomStringConvertible {
  public var description: String {
    name ?? "unknown"
  }
}

// MARK: - AVCodecHWConfig

typealias CAVCodecHWConfig = CFFmpeg.AVCodecHWConfig

public struct AVCodecHWConfig {
  var native: UnsafePointer<CAVCodecHWConfig>

  init(native: UnsafePointer<CAVCodecHWConfig>) {
    self.native = native
  }

  /// A hardware pixel format which the codec can use.
  public var pixelFormat: AVPixelFormat {
    native.pointee.pix_fmt
  }

  /// Bit set of `AVCodecHWConfig.Method` flags, describing the possible setup methods
  /// which can be used with this configuration.
  public var methods: Method {
    Method(rawValue: native.pointee.methods)
  }

  /// The device type associated with the configuration.
  ///
  /// Must be set for `AVCodecHWConfig.Method.hwDeviceContext` and `AVCodecHWConfig.Method.hwFramesContext`,
  /// otherwise unused.
  public var deviceType: AVHWDeviceType {
    AVHWDeviceType(native: native.pointee.device_type)
  }
}

// MARK: - AVCodecHWConfig.Method

extension AVCodecHWConfig {
  /// Flags used by `methods`.
  public struct Method: OptionSet {
    /// The codec supports this format via the `AVCodecContext.hwDeviceContext` interface.
    ///
    /// When selecting this format, `AVCodecContext.hwDeviceContext` should
    /// have been set to a device of the specified type before calling
    /// `AVCodecContext.openCodec(options:)`.
    public static let hwDeviceContext = Method(
      rawValue: Int32(AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX))

    /// The codec supports this format via the `AVCodecContext.hwFramesContext` interface.
    ///
    /// When selecting this format for a decoder, `AVCodecContext.hwFramesContext`
    /// should be set to a suitable frames context inside the `AVCodecContext.getFormat` callback.
    /// The frames context must have been created on a device of the specified type.
    public static let hwFramesContext = Method(
      rawValue: Int32(AV_CODEC_HW_CONFIG_METHOD_HW_FRAMES_CTX))

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

    public init(rawValue: Int32) { self.rawValue = rawValue }
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
  var native: UnsafeMutablePointer<CAVBuffer>!
  var owned: Bool = false

  init(native: UnsafeMutablePointer<CAVBuffer>) {
    self.native = native
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
    var pm = options?.avDict
    defer { av_dict_free(&pm) }

    try throwIfFail(av_hwdevice_ctx_create(&native, deviceType.native, device, pm, 0))
    self.owned = true
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
    try throwIfFail(
      av_hwdevice_ctx_create_derived(&native, deviceType.native, deviceContext.native, 0))
    self.owned = true
  }

  deinit {
    if owned {
      av_buffer_unref(&native)
    }
  }
}

// MARK: - AVHWFrameTransferDirection

public enum AVHWFrameTransferDirection: UInt32 {
  /// Transfer the data from the queried hw frame.
  case from
  /// Transfer the data to the queried hw frame.
  case to

  var native: CFFmpeg.AVHWFrameTransferDirection {
    CFFmpeg.AVHWFrameTransferDirection(rawValue)
  }

  init(native: CFFmpeg.AVHWFrameTransferDirection) {
    guard let direction = AVHWFrameTransferDirection(rawValue: native.rawValue) else {
      fatalError("Unknown frame transfer direction: \(native)")
    }
    self = direction
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
  var nativeBuffer: UnsafeMutablePointer<CAVBuffer>!
  let native: UnsafeMutablePointer<CAVHWFramesContext>
  var owned: Bool = false

  init(nativeBuffer: UnsafeMutablePointer<CAVBuffer>) {
    self.nativeBuffer = nativeBuffer
    self.native = UnsafeMutableRawPointer(nativeBuffer.pointee.data)!
      .bindMemory(to: CAVHWFramesContext.self, capacity: 1)
  }

  /// Create an `AVHWFramesContext` tied to a given device context.
  ///
  /// - Parameter deviceContext: a `AVHWDeviceContext` instance.
  public init(deviceContext: AVHWDeviceContext) {
    self.nativeBuffer = av_hwframe_ctx_alloc(deviceContext.native)
    self.native = UnsafeMutableRawPointer(nativeBuffer.pointee.data)!
      .bindMemory(to: CAVHWFramesContext.self, capacity: 1)
    self.owned = true
  }

  deinit {
    if owned {
      av_buffer_unref(&nativeBuffer)
    }
  }

  /// A reference to the parent `AVHWDeviceContext`.
  public var deviceContext: AVHWDeviceContext {
    AVHWDeviceContext(native: native.pointee.device_ref)
  }

  /// The pixel format identifying the underlying HW surface type.
  /// Must be a hwaccel format, i.e. the corresponding descriptor must have the
  /// `AV_PIX_FMT_FLAG_HWACCEL` flag set.
  ///
  /// Must be set by the user before calling `initialize()`.
  public var pixelFormat: AVPixelFormat {
    get { native.pointee.format }
    set { native.pointee.format = newValue }
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
    get { native.pointee.sw_format }
    set { native.pointee.sw_format = newValue }
  }

  /// The width of the frames in this pool.
  ///
  /// Must be set by the user before calling `initialize()`.
  public var width: Int {
    get { Int(native.pointee.width) }
    set { native.pointee.width = Int32(newValue) }
  }

  /// The height of the frames in this pool.
  ///
  /// Must be set by the user before calling `initialize()`.
  public var height: Int {
    get { Int(native.pointee.height) }
    set { native.pointee.height = Int32(newValue) }
  }

  /// Initial size of the frame pool. If a device type does not support
  /// dynamically resizing the pool, then this is also the maximum pool size.
  ///
  /// May be set by the caller before calling `initialize()`.
  /// Must be set if pool is `nil` and the device type does not support dynamic pools.
  public var initialPoolSize: Int {
    get { Int(native.pointee.initial_pool_size) }
    set { native.pointee.initial_pool_size = Int32(newValue) }
  }

  /// Finalize the context before use. This function must be called after the
  /// context is filled with all the required information and before it is attached
  /// to any frames.
  ///
  /// - Throws: AVError
  public func initialize() throws {
    try throwIfFail(av_hwframe_ctx_init(nativeBuffer))
  }

  /// Allocate a new frame attached to the given `AVHWFramesContext`.
  ///
  /// - Parameter frame: an empty (freshly allocated or unreffed) frame to be filled with
  ///   newly allocated buffers.
  /// - Throws: AVError
  public func allocBuffer(frame: AVFrame) throws {
    try throwIfFail(av_hwframe_get_buffer(nativeBuffer, frame.native, 0))
  }

  /// Get a list of possible source or target formats usable in `AVFrame.transferData(from:)`.
  ///
  /// - Parameter direction: the direction of the transfer
  /// - Returns: supported pixel formats
  public func getPixelFormats(_ direction: AVHWFrameTransferDirection) -> [AVPixelFormat]? {
    var ptr: UnsafeMutablePointer<AVPixelFormat>?
    defer { av_free(ptr) }
    if av_hwframe_transfer_get_formats(nativeBuffer, direction.native, &ptr, 0) != 0 {
      return nil
    }
    return values(ptr, until: .none)
  }
}

extension AVFrame {
  /// For hwaccel-format frames, this should be a reference to the `AVHWFramesContext`
  /// describing the frame.
  public var hwFramesContext: AVHWFramesContext? {
    native.pointee.hw_frames_ctx.map(AVHWFramesContext.init(nativeBuffer:))
  }

  /// Copy data from a hw surface.
  ///
  /// The source frame must have an `AVHWFramesContext` attached, and the pixel format of
  /// the destination frame must use one of the formats returned by
  /// `AVHWFramesContext.getPixelFormats(.from)`.
  ///
  /// The destination frame may be "clean" (i.e. with `data`/`buffer` pointers unset),
  /// in which case the data buffers will be allocated by this function using `allocBuffer(align:)`.
  /// If the pixel format of the destination frame is set, then this format will be used,
  /// otherwise (when the destination frame's pixel format is `AVPixelFormat.none`) the
  /// first acceptable format will be chosen.
  ///
  /// The two frames must have matching allocated dimensions (i.e. equal to
  /// `AVHWFramesContext.width`/`AVHWFramesContext.height`), since not all device types
  /// support transferring a sub-rectangle of the whole surface.
  /// The display dimensions (i.e. `AVFrame.width`/`AVFrame.height`) may be smaller than
  /// the allocated dimensions, but also have to be equal for both frames. When the
  /// display dimensions are smaller than the allocated dimensions, the content of the
  /// padding in the destination frame is unspecified.
  ///
  /// - Parameter frame: the source frame
  /// - Throws: AVError
  public func transferData(from frame: AVFrame) throws {
    try throwIfFail(av_hwframe_transfer_data(native, frame.native, 0))
  }
}
