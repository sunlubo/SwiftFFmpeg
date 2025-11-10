//
//  AVStream.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

// MARK: - AVDiscard

public enum AVDiscard: Int32 {
  /// discard nothing
  case none = -16
  /// discard useless packets like 0 size packets in avi
  case `default` = 0
  /// discard all non reference
  case nonRef = 8
  /// discard all bidirectional frames
  case bidir = 16
  /// discard all non intra frames
  case nonIntra = 24
  /// discard all frames except keyframes
  case nonKey = 32
  /// discard all
  case all = 48

  var native: CFFmpeg.AVDiscard {
    CFFmpeg.AVDiscard(rawValue)
  }

  init(native: CFFmpeg.AVDiscard) {
    guard let discard = AVDiscard(rawValue: native.rawValue) else {
      fatalError("Unknown discard: \(native)")
    }
    self = discard
  }
}

// MARK: - AVStream

typealias CAVStream = CFFmpeg.AVStream

/// Stream structure.
public final class AVStream {
  let native: UnsafeMutablePointer<CAVStream>

  init(native: UnsafeMutablePointer<CAVStream>) {
    self.native = native
  }

  /// Stream index in `AVFormatContext`.
  public var index: Int {
    Int(native.pointee.index)
  }

  /// Format-specific stream ID.
  ///
  /// - encoding: Set by the user, replaced by libavformat if left unset.
  /// - decoding: Set by libavformat.
  public var id: Int32 {
    get { native.pointee.id }
    set { native.pointee.id = newValue }
  }

  /// This is the fundamental unit of time (in seconds) in terms of which frame timestamps are represented.
  ///
  /// - encoding: May be set by the caller before `AVFormatContext.writeHeader(options:)` to provide a hint
  ///   to the muxer about the desired timebase. In `AVFormatContext.writeHeader(options:)`, the muxer will
  ///   overwrite this field with the timebase that will actually be used for the timestamps written into the
  ///   file (which may or may not be related to the user-provided one, depending on the format).
  /// - decoding: Set by libavformat.
  public var timebase: AVRational {
    get { native.pointee.time_base }
    set { native.pointee.time_base = newValue }
  }

  /// pts of the first frame of the stream in presentation order, in stream timebase.
  public var startTime: Int64 {
    native.pointee.start_time
  }

  public var duration: Int64 {
    native.pointee.duration
  }

  /// Number of frames in this stream if known or 0.
  public var frameCount: Int {
    Int(native.pointee.nb_frames)
  }

  /// Selects which packets can be discarded at will and do not need to be demuxed.
  public var discard: AVDiscard {
    get { AVDiscard(native: native.pointee.discard) }
    set { native.pointee.discard = newValue.native }
  }

  /// sample aspect ratio (0 if unknown)
  ///
  /// - encoding: Set by user.
  /// - decoding: Set by libavformat.
  public var sampleAspectRatio: AVRational {
    native.pointee.sample_aspect_ratio
  }

  /// The metadata of the stream.
  public var metadata: [String: String] {
    get {
      var dict = [String: String]()
      var prev: UnsafeMutablePointer<AVDictionaryEntry>?
      while let tag = av_dict_get(native.pointee.metadata, "", prev, AV_DICT_IGNORE_SUFFIX) {
        dict[String(cString: tag.pointee.key)] = String(cString: tag.pointee.value)
        prev = tag
      }
      return dict
    }
    set { native.pointee.metadata = newValue.avDict }
  }

  /// Average framerate.
  ///
  /// - demuxing: May be set by libavformat when creating the stream or in
  ///   `AVFormatContext.findStreamInfo(options:)`.
  /// - muxing: May be set by the caller before `AVFormatContext.writeHeader(options:)`.
  public var averageFramerate: AVRational {
    get { native.pointee.avg_frame_rate }
    set { native.pointee.avg_frame_rate = newValue }
  }

  /// Real base framerate of the stream.
  /// This is the lowest framerate with which all timestamps can be represented accurately
  /// (it is the least common multiple of all framerates in the stream). Note, this value is just a guess!
  /// For example, if the timebase is 1/90000 and all frames have either approximately 3600 or 1800 timer ticks,
  /// then realFramerate will be 50/1.
  public var realFramerate: AVRational {
    native.pointee.r_frame_rate
  }

  /// Codec parameters associated with this stream.
  ///
  /// - demuxing: Filled by libavformat on stream creation or in `AVFormatContext.findStreamInfo(options:)`.
  /// - muxing: Filled by the caller before `AVFormatContext.writeHeader(options:)`.
  public var codecParameters: AVCodecParameters {
    AVCodecParameters(native: native.pointee.codecpar)
  }

  /// The media type of the stream.
  public var mediaType: AVMediaType {
    codecParameters.mediaType
  }
}
