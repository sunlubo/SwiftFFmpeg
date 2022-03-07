//
//  Timestamp.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/9.
//

import CFFmpeg

public enum AVTimestamp {
  /// Internal timebase represented as integer
  public static let timebase = AV_TIME_BASE
  /// Internal timebase represented as fractional value
  public static let timebaseQ = av_get_time_base_q()
  /// Undefined timestamp value.
  ///
  /// Usually reported by demuxer that work on containers that do not provide either pts or dts.
  public static let noPTS = swift_AV_NOPTS_VALUE // ((int64_t)UINT64_C(0x8000000000000000)) == Int64.min

  /// Compare two timestamps each in its own timebase.
  ///
  /// - Warning: The result of the function is undefined if one of the timestamps is outside the `int64_t` range
  ///   when represented in the other's timebase.
  ///
  /// - Returns: One of the following values:
  ///   - -1 if `ts_a` is before `ts_b`
  ///   -  1 if `ts_a` is after `ts_b`
  ///   -  0 if they represent the same position
  public static func compare(
    _ ts_a: Int64, _ tb_a: AVRational,
    _ ts_b: Int64, _ tb_b: AVRational
  ) -> Int {
    Int(av_compare_ts(ts_a, tb_a, ts_b, tb_b))
  }
}
