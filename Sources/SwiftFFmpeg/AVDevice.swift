//
//  AVDevice.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/17.
//

import CFFmpeg

// MARK: - AVDeviceRect

public typealias AVDeviceRect = CFFmpeg.AVDeviceRect

// MARK: - AVAppToDevMessageType

/// Message types used by `AVFormatContext.sendMessageToDevice(type:data:)`.
public typealias AVAppToDevMessageType = CFFmpeg.AVAppToDevMessageType

extension AVAppToDevMessageType {
    /// Dummy message.
    public static let none = AV_APP_TO_DEV_NONE
    /// Window size change message.
    ///
    /// Message is sent to the device every time the application changes the size
    /// of the window device renders to.
    /// Message should also be sent right after window is created.
    ///
    /// data: `AVDeviceRect`: new window size.
    public static let windowSize = AV_APP_TO_DEV_WINDOW_SIZE
    /// Repaint request message.
    ///
    /// Message is sent to the device when window has to be repainted.
    ///
    /// data: `AVDeviceRect`: area required to be repainted.
    ///       `nil`: whole area is required to be repainted.
    public static let windowRepaint = AV_APP_TO_DEV_WINDOW_REPAINT
    /// Request pause/play.
    ///
    /// Application requests pause/unpause playback.
    /// Mostly usable with devices that have internal buffer.
    /// By default devices are not paused.
    ///
    /// data: `nil`.
    public static let pause = AV_APP_TO_DEV_PAUSE
    public static let togglePause = AV_APP_TO_DEV_TOGGLE_PAUSE
    /// Volume control message.
    ///
    /// Set volume level. It may be device-dependent if volume
    /// is changed per stream or system wide. Per stream volume
    /// change is expected when possible.
    ///
    /// data: `Double`: new volume with range of __0.0 - 1.0__.
    public static let setVolume = AV_APP_TO_DEV_SET_VOLUME
    /// Mute control messages.
    ///
    /// Change mute state. It may be device-dependent if mute status
    /// is changed per stream or system wide. Per stream mute status
    /// change is expected when possible.
    ///
    /// data: `nil`.
    public static let mute = AV_APP_TO_DEV_MUTE
    public static let unmute = AV_APP_TO_DEV_UNMUTE
    public static let toggleMute = AV_APP_TO_DEV_TOGGLE_MUTE
    /// Get volume/mute messages.
    ///
    /// Force the device to send `AVDevToAppMessageType.volumeLevelChanged` or
    /// `AVDevToAppMessageType.muteStateChanged` command respectively.
    ///
    /// data: `nil`.
    public static let getVolume = AV_APP_TO_DEV_GET_VOLUME
    public static let getMute = AV_APP_TO_DEV_GET_MUTE
}

// MARK: - AVDevToAppMessageType

/// Message types used by `AVFormatContext.sendMessageToApplication(type:data:)`.
public typealias AVDevToAppMessageType = CFFmpeg.AVDevToAppMessageType

extension AVDevToAppMessageType {
    /// Dummy message.
    public static let none = AV_DEV_TO_APP_NONE
    /// Create window buffer message.
    ///
    /// Device requests to create a window buffer. Exact meaning is device-
    /// and application-dependent. Message is sent before rendering first
    /// frame and all one-shot initializations should be done here.
    /// Application is allowed to ignore preferred window buffer size.
    ///
    /// - Note: Application is obligated to inform about window buffer size
    ///   with `AVAppToDevMessageType.windowSize` message.
    ///
    /// data: `AVDeviceRect`: preferred size of the window buffer.
    ///       `nil`: no preferred size of the window buffer.
    public static let createWindowBuffer = AV_DEV_TO_APP_CREATE_WINDOW_BUFFER
    /// Prepare window buffer message.
    ///
    /// Device requests to prepare a window buffer for rendering.
    /// Exact meaning is device- and application-dependent.
    /// Message is sent before rendering of each frame.
    ///
    /// data: `nil`.
    public static let prepareWindowBuffer = AV_DEV_TO_APP_PREPARE_WINDOW_BUFFER
    /// Display window buffer message.
    ///
    /// Device requests to display a window buffer.
    /// Message is sent when new frame is ready to be displayed.
    /// Usually buffers need to be swapped in handler of this message.
    ///
    /// data: `nil`.
    public static let displayWindowBuffer = AV_DEV_TO_APP_DISPLAY_WINDOW_BUFFER
    /// Destroy window buffer message.
    ///
    /// Device requests to destroy a window buffer.
    /// Message is sent when device is about to be destroyed and window
    /// buffer is not required anymore.
    ///
    /// data: `nil`.
    public static let destroyWindowBuffer = AV_DEV_TO_APP_DESTROY_WINDOW_BUFFER
    /// Buffer fullness status messages.
    ///
    /// Device signals buffer overflow/underflow.
    ///
    /// data: `nil`.
    public static let bufferOverflow = AV_DEV_TO_APP_BUFFER_OVERFLOW
    public static let bufferUnderflow = AV_DEV_TO_APP_BUFFER_UNDERFLOW
    /// Buffer readable/writable.
    ///
    /// Device informs that buffer is readable/writable.
    /// When possible, device informs how many bytes can be read/write.
    ///
    /// - Warning: Device may not inform when number of bytes than can be read/write changes.
    ///
    /// data: `Int64`: amount of bytes available to read/write.
    ///       `nil`: amount of bytes available to read/write is not known.
    public static let bufferReadable = AV_DEV_TO_APP_BUFFER_READABLE
    public static let bufferWritable = AV_DEV_TO_APP_BUFFER_WRITABLE
    /// Mute state change message.
    ///
    /// Device informs that mute state has changed.
    ///
    /// data: `Int32`: 0 for not muted state, non-zero for muted state.
    public static let muteStateChanged = AV_DEV_TO_APP_MUTE_STATE_CHANGED
    /// Volume level change message.
    ///
    /// Device informs that volume level has changed.
    ///
    /// data: `Double`: new volume with range of __0.0 - 1.0__.
    public static let volumeLevelChanged = AV_DEV_TO_APP_VOLUME_LEVEL_CHANGED
}

// MARK: - AVDevice

public enum AVDevice {

    /// Return the libavdevice build-time configuration.
    public static var configuration: String {
        String(cString: avdevice_configuration())
    }

    /// Get all registered audio input devices.
    public static var supportedAudioInputDevices: [AVInputFormat] {
        var list = [AVInputFormat]()
        var prev: UnsafeMutablePointer<CAVInputFormat>?
        while let fmtPtr = av_input_audio_device_next(prev) {
            list.append(AVInputFormat(cFormatPtr: fmtPtr))
            prev = fmtPtr
        }
        return list
    }

    /// Get all registered video input devices.
    public static var supportedVideoInputDevices: [AVInputFormat] {
        var list = [AVInputFormat]()
        var prev: UnsafeMutablePointer<CAVInputFormat>?
        while let fmtPtr = av_input_video_device_next(prev) {
            list.append(AVInputFormat(cFormatPtr: fmtPtr))
            prev = fmtPtr
        }
        return list
    }

    /// Get all registered audio output devices.
    public static var supportedAudioOutputDevices: [AVOutputFormat] {
        var list = [AVOutputFormat]()
        var prev: UnsafeMutablePointer<CAVOutputFormat>?
        while let fmtPtr = av_output_audio_device_next(prev) {
            list.append(AVOutputFormat(cFormatPtr: fmtPtr))
            prev = fmtPtr
        }
        return list
    }

    /// Get all registered video output devices.
    public static var supportedVideoOutputDevices: [AVOutputFormat] {
        var list = [AVOutputFormat]()
        var prev: UnsafeMutablePointer<CAVOutputFormat>?
        while let fmtPtr = av_output_video_device_next(prev) {
            list.append(AVOutputFormat(cFormatPtr: fmtPtr))
            prev = fmtPtr
        }
        return list
    }
}

extension AVFormatContext {

    /// Send control message from application to device.
    ///
    /// - Parameters:
    ///   - type: message type.
    ///   - data: message data. Exact type depends on message type.
    /// - Throws:
    ///     - `AVError.noSystem` when device doesn't implement handler of the message.
    ///     - othrer errors
    public func sendMessageToDevice(
        type: AVAppToDevMessageType,
        data: UnsafeMutableRawBufferPointer?
    ) throws {
        try throwIfFail(
            avdevice_app_to_dev_control_message(cContextPtr, type, data?.baseAddress, data?.count ?? 0)
        )
    }

    /// Send control message from device to application.
    ///
    /// - Parameters:
    ///   - type: message type.
    ///   - data: message data. Can be `nil`.
    /// - Throws:
    ///     - `AVError.noSystem` when device doesn't implement handler of the message.
    ///     - othrer errors
    public func sendMessageToApplication(
        type: AVDevToAppMessageType,
        data: UnsafeMutableRawBufferPointer?
    ) throws {
        try throwIfFail(
            avdevice_dev_to_app_control_message(cContextPtr, type, data?.baseAddress, data?.count ?? 0)
        )
    }
}

// MARK: - AVDeviceCapabilitiesQuery

typealias CAVDeviceCapabilitiesQuery = CFFmpeg.AVDeviceCapabilitiesQuery

/// Structure describes device capabilities.
///
/// It is used by devices in conjunction with `av_device_capabilities` `AVOption` table
/// to implement capabilities probing API based on `AVOption` API. Should not be used directly.
public final class AVDeviceCapabilitiesQuery {
    private let formatContext: AVFormatContext
    private let cQueryPtr: UnsafeMutablePointer<CAVDeviceCapabilitiesQuery>
    private var cQuery: CAVDeviceCapabilitiesQuery { cQueryPtr.pointee }

    /// Initialize capabilities probing API based on `AVOption` API.
    ///
    /// - Parameters:
    ///   - formatContext: Context of the device.
    ///   - options: An dictionary filled with device-private options.
    ///     The same options must be passed later to `AVFormatContext.writeHeader(options:)`
    ///     for output devices or `AVFormatContext.openInput(_:format:options:)` for input devices,
    ///     or at any other place that affects device-private options.
    /// - Throws: AVError
    public init(formatContext: AVFormatContext, options: [String: String]? = nil) throws {
        var pm: OpaquePointer? = options?.toAVDict()
        defer { av_dict_free(&pm) }

        var queryPtr: UnsafeMutablePointer<CAVDeviceCapabilitiesQuery>?
        let ret = avdevice_capabilities_create(&queryPtr, formatContext.cContextPtr, &pm)
        try throwIfFail(ret)
        self.formatContext = formatContext
        self.cQueryPtr = queryPtr!
    }

    public var codec: AVCodecID {
        cQuery.codec
    }

    public var sampleFormat: AVCodecID {
        cQuery.codec
    }

    public var sampleRate: Int {
        Int(cQuery.sample_rate)
    }

    public var channelCount: Int {
        Int(cQuery.channels)
    }

    public var channelLayout: AVChannelLayout {
        AVChannelLayout(rawValue: UInt64(cQuery.channel_layout))
    }

    public var pixelFormat: AVCodecID {
        cQuery.codec
    }

    public var windowWidth: Int {
        Int(cQuery.window_width)
    }

    public var windowHeight: Int {
        Int(cQuery.window_height)
    }

    public var frameWidth: Int {
        Int(cQuery.frame_width)
    }

    public var frameHeight: Int {
        Int(cQuery.frame_height)
    }

    public var fps: AVRational {
        cQuery.fps
    }

    deinit {
        var pb: UnsafeMutablePointer<CAVDeviceCapabilitiesQuery>? = cQueryPtr
        avdevice_capabilities_free(&pb, formatContext.cContextPtr)
    }
}

// MARK: - AVDeviceInfo

typealias CAVDeviceInfo = CFFmpeg.AVDeviceInfo

/// Structure describes basic parameters of the device.
public struct AVDeviceInfo {
    private let cDeviceInfoPtr: UnsafeMutablePointer<CAVDeviceInfo>
    private var cDeviceInfo: CAVDeviceInfo { cDeviceInfoPtr.pointee }

    init(cDeviceInfoPtr: UnsafeMutablePointer<CAVDeviceInfo>) {
        self.cDeviceInfoPtr = cDeviceInfoPtr
    }

    /// The name of the device.
    public var name: String {
        String(cString: cDeviceInfo.device_name)
    }

    /// The human friendly name of the device.
    public var description: String {
        String(cString: cDeviceInfo.device_description)
    }
}

// MARK: - AVDeviceInfoList

typealias CAVDeviceInfoList = CFFmpeg.AVDeviceInfoList

/// List of devices.
public final class AVDeviceInfoList {
    private let cDeviceInfoListPtr: UnsafeMutablePointer<CAVDeviceInfoList>
    private var cDeviceInfoList: CAVDeviceInfoList { cDeviceInfoListPtr.pointee }

    private var freeWhenDone: Bool = false

    init(cDeviceInfoListPtr: UnsafeMutablePointer<CAVDeviceInfoList>) {
        self.cDeviceInfoListPtr = cDeviceInfoListPtr
    }

    /// List devices.
    ///
    /// Returns available device names and their parameters.
    ///
    /// - Note: Some devices may accept system-dependent device names that cannot be autodetected.
    ///   The list returned by this function cannot be assumed to be always completed.
    ///
    /// - Parameter formatContext: device context
    /// - Throws: AVError
    public init(formatContext: AVFormatContext) throws {
        var listPtr: UnsafeMutablePointer<CAVDeviceInfoList>!
        let ret = avdevice_list_devices(formatContext.cContextPtr, &listPtr)
        try throwIfFail(ret)
        self.cDeviceInfoListPtr = listPtr
        self.freeWhenDone = true
    }

    /// list of autodetected devices
    public var devices: [AVDeviceInfo] {
        var list = [AVDeviceInfo]()
        for i in 0 ..< deviceCount {
            list.append(AVDeviceInfo(cDeviceInfoPtr: cDeviceInfoList.devices[i]!))
        }
        return list
    }

    /// number of autodetected devices
    public var deviceCount: Int {
        Int(cDeviceInfoList.nb_devices)
    }

    /// index of default device or -1 if no default
    public var defaultDeviceIndex: Int {
        Int(cDeviceInfoList.default_device)
    }

    deinit {
        if freeWhenDone {
            var pb: UnsafeMutablePointer<CAVDeviceInfoList>?
            avdevice_free_list_devices(&pb)
        }
    }

    /// List devices.
    ///
    /// Returns available device names and their parameters.
    /// These are convinient wrappers for `init(formatContext:)`.
    /// Device context is allocated and deallocated internally.
    ///
    /// - Note: device argument takes precedence over device_name when both are set.
    ///
    /// - Parameters:
    ///   - device: device format. May be `nil` if device name is set.
    ///   - deviceName: device name. May be `nil` if device format is set.
    ///   - options: An dictionary filled with device-private options.
    ///     The same options must be passed later to `AVFormatContext.writeHeader(options:)`
    ///     for output devices or `AVFormatContext.openInput(_:format:options:)` for input devices,
    ///     or at any other place that affects device-private options.
    /// - Returns: list of autodetected devices
    /// - Throws: AVError
    public static func listInputSources(
        device: AVInputFormat?,
        deviceName: String?,
        options: [String: String]? = nil
    ) throws -> AVDeviceInfoList {
        var pm: OpaquePointer? = options?.toAVDict()
        defer { av_dict_free(&pm) }

        var listPtr: UnsafeMutablePointer<CAVDeviceInfoList>!
        let ret = avdevice_list_input_sources(device?.cFormatPtr, deviceName, pm, &listPtr)
        try throwIfFail(ret)
        return AVDeviceInfoList(cDeviceInfoListPtr: listPtr)
    }

    public static func listInputSinks(
        device: AVOutputFormat?,
        deviceName: String? = nil,
        options: [String: String]? = nil
    ) throws -> AVDeviceInfoList {
        var pm: OpaquePointer? = options?.toAVDict()
        defer { av_dict_free(&pm) }

        var listPtr: UnsafeMutablePointer<CAVDeviceInfoList>!
        let ret = avdevice_list_output_sinks(device?.cFormatPtr, deviceName, pm, &listPtr)
        try throwIfFail(ret)
        return AVDeviceInfoList(cDeviceInfoListPtr: listPtr)
    }
}
