//
//  AVLog.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/13.
//

import CFFmpeg

// MARK: - AVLog

public enum AVLog {
  /// Get/set the log level.
  public static var level: Level {
    get { Level(rawValue: av_log_get_level()) }
    set { av_log_set_level(newValue.rawValue) }
  }

  /// Send the specified message to the log if the level is less than or equal
  /// to the current level. By default, all logging messages are sent to
  /// stderr. This behavior can be altered by setting a different logging callback
  /// function.
  public static func log(level: Level, message: String) {
    swift_log(nil, level.rawValue, "\(message)\n")
  }

  /// Send the specified message to the log if the level is less than or equal
  /// to the current level. By default, all logging messages are sent to
  /// stderr. This behavior can be altered by setting a different logging callback
  /// function.
  public static func log(context: AVClassSupport, level: Level, message: String) {
    context.withUnsafeObjectPointer { ptr in
      swift_log(ptr, level.rawValue, "\(message)\n")
    }
  }
}

// MARK: - AVLog.Level

extension AVLog {
  /// Log level
  public struct Level: OptionSet {
    /// Print no output.
    public static let quiet = Level(rawValue: AV_LOG_QUIET)
    // Something went really wrong and we will crash now.
    public static let panic = Level(rawValue: AV_LOG_PANIC)
    /// Something went wrong and recovery is not possible.
    /// For example, no header was found for a format which depends
    /// on headers or an illegal combination of parameters is used.
    public static let fatal = Level(rawValue: AV_LOG_FATAL)
    /// Something went wrong and cannot losslessly be recovered.
    /// However, not all future data is affected.
    public static let error = Level(rawValue: AV_LOG_ERROR)
    /// Something somehow does not look correct. This may or may not
    /// lead to problems. An example would be the use of '-vstrict -2'.
    public static let warning = Level(rawValue: AV_LOG_WARNING)
    /// Standard information.
    public static let info = Level(rawValue: AV_LOG_INFO)
    /// Detailed information.
    public static let verbose = Level(rawValue: AV_LOG_VERBOSE)
    /// Stuff which is only useful for libav* developers.
    public static let debug = Level(rawValue: AV_LOG_DEBUG)
    /// Extremely verbose debugging, useful for libav* development.
    public static let trace = Level(rawValue: AV_LOG_TRACE)

    public let rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }
  }
}
