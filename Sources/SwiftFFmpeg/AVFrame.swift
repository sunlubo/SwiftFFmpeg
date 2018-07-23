//
//  AVFrame.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

internal typealias CAVFrame = CFFmpeg.AVFrame

/// This structure describes decoded (raw) audio or video data.
public final class AVFrame {
    internal let framePtr: UnsafeMutablePointer<CAVFrame>
    internal var frame: CAVFrame { return framePtr.pointee }

    /// Creates an `AVFrame` and set its fields to default values.
    public init?() {
        guard let framePtr = av_frame_alloc() else {
            return nil
        }
        self.framePtr = framePtr
    }

    /// Pointer to the picture/channel planes.
    public var data: [UnsafeMutablePointer<UInt8>?] {
        get {
            return [
                frame.data.0, frame.data.1, frame.data.2, frame.data.3,
                frame.data.4, frame.data.5, frame.data.6, frame.data.7
            ]
        }
        set {
            var list = newValue
            while list.count < AV_NUM_DATA_POINTERS {
                list.append(nil)
            }
            framePtr.pointee.data = (
                list[0], list[1], list[2], list[3],
                list[4], list[5], list[6], list[7]
            )
        }
    }

    /// For video, size in bytes of each picture line.
    ///
    /// For audio, size in bytes of each plane.
    public var linesize: [Int] {
        get {
            let value = [
                frame.linesize.0, frame.linesize.1, frame.linesize.2, frame.linesize.3,
                frame.linesize.4, frame.linesize.5, frame.linesize.6, frame.linesize.7
            ]
            return value.map({ Int($0) })
        }
        set {
            var list = newValue.map({ Int32($0) })
            while list.count < AV_NUM_DATA_POINTERS {
                list.append(0)
            }
            framePtr.pointee.linesize = (
                list[0], list[1], list[2], list[3],
                list[4], list[5], list[6], list[7]
            )
        }
    }

    /// Format of the frame, -1 if unknown or unset.
    ///
    /// Values correspond to AVPixelFormat for video frames, AVSampleFormat for audio.
    public var format: Int32 {
        get { return frame.format }
        set { framePtr.pointee.format = newValue }
    }

    /// Presentation timestamp in time_base units (time when frame should be shown to user).
    public var pts: Int64 {
        get { return frame.pts }
        set { framePtr.pointee.pts = newValue }
    }

    /// Picture number in bitstream order.
    public var codedPictureNumber: Int {
        return Int(frame.coded_picture_number)
    }

    /// Picture number in display order.
    public var displayPictureNumber: Int {
        return Int(frame.display_picture_number)
    }

    /// Size of the corresponding packet containing the compressed frame. It is set to a negative value if unknown.
    public var pktSize: Int {
        return Int(frame.pkt_size)
    }

    /// Unreference all the buffers referenced by frame and reset the frame fields.
    public func unref() {
        av_frame_unref(framePtr)
    }

    /// Allocate new buffer(s) for audio or video data.
    ///
    /// - Parameter alignment: Required buffer size alignment.
    ///   - If equal to 0, alignment will be chosen automatically for the current CPU.
    ///   - It is highly recommended to pass 0 here unless you know what you are doing.
    /// - Throws: AVError
    public func allocBuffer(alignment: Int32 = 0) throws {
        try throwIfFail(av_frame_get_buffer(framePtr, alignment))
    }

    /// Ensure that the frame data is writable, avoiding data copy if possible.
    ///
    /// Do nothing if the frame is writable, allocate new buffers and copy the data if it is not.
    ///
    /// - Throws: AVError
    public func makeWritable() throws {
        try throwIfFail(av_frame_make_writable(framePtr))
    }

    deinit {
        var ptr: UnsafeMutablePointer<CAVFrame>? = framePtr
        av_frame_free(&ptr)
    }
}

// MARK: - Video

extension AVFrame {

    /// picture width
    public var width: Int {
        get { return Int(frame.width) }
        set { framePtr.pointee.width = Int32(newValue) }
    }

    /// picture height
    public var height: Int {
        get { return Int(frame.height) }
        set { framePtr.pointee.height = Int32(newValue) }
    }

    /// Pixel format.
    public var pixFmt: AVPixelFormat {
        get { return AVPixelFormat(frame.format) }
        set { framePtr.pointee.format = newValue.rawValue }
    }

    /// Returns whether this frame is key frame.
    public var isKeyFrame: Bool {
        return frame.key_frame == 1
    }

    /// Picture type of the frame.
    public var pictType: AVPictureType {
        return frame.pict_type
    }

    /// Sample aspect ratio for the video frame, 0/1 if unknown/unspecified.
    public var sampleAspectRatio: AVRational {
        get { return frame.sample_aspect_ratio }
        set { framePtr.pointee.sample_aspect_ratio = newValue }
    }
}

// MARK: - Audio

extension AVFrame {

    /// Sample rate of the audio data.
    public var sampleRate: Int32 {
        get { return frame.sample_rate }
        set { framePtr.pointee.sample_rate = newValue }
    }

    /// Channel layout of the audio data.
    public var channelLayout: UInt64 {
        get { return frame.channel_layout }
        set { framePtr.pointee.channel_layout = newValue }
    }

    /// Sample format.
    public var sampleFmt: AVSampleFormat {
        get { return AVSampleFormat(frame.format) }
        set { framePtr.pointee.format = newValue.rawValue }
    }

    /// Number of audio samples (per channel) described by this frame.
    public var sampleCount: Int32 {
        get { return frame.nb_samples }
        set { framePtr.pointee.nb_samples = newValue }
    }

    /// Number of audio channels.
    public var channelCount: Int32 {
        get { return frame.channels }
        set { framePtr.pointee.channels = newValue }
    }
}
