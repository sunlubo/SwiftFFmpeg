//
//  Math.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/9.
//

import CFFmpeg

// MARK: - AVRational

/// Rational number (pair of numerator and denominator).
public typealias AVRational = CFFmpeg.AVRational

extension AVRational {

  /// Convert an `AVRational` to a `Double`.
  public var toDouble: Double {
    av_q2d(self)
  }

  /// Invert a rational. `1 / q`
  public var inverted: AVRational {
    av_inv_q(self)
  }
}

extension AVRational: Equatable {

  public static func == (lhs: AVRational, rhs: AVRational) -> Bool {
    av_cmp_q(lhs, rhs) == 0
  }
}

extension AVRational {

  /// Add two rationals.
  public static func + (lhs: AVRational, rhs: AVRational) -> AVRational {
    av_add_q(lhs, rhs)
  }

  /// Subtract one rational from another.
  public static func - (lhs: AVRational, rhs: AVRational) -> AVRational {
    av_sub_q(lhs, rhs)
  }

  /// Multiply two rationals.
  public static func * (lhs: AVRational, rhs: AVRational) -> AVRational {
    av_mul_q(lhs, rhs)
  }

  /// Divide one rational by another.
  public static func / (lhs: AVRational, rhs: AVRational) -> AVRational {
    av_div_q(lhs, rhs)
  }
}

// MARK: - AVRounding

/// Rounding methods.
public enum AVRounding: UInt32 {
  /// Round toward zero.
  case zero = 0
  /// Round away from zero.
  case inf = 1
  /// Round toward -infinity.
  case down = 2
  /// Round toward +infinity.
  case up = 3
  /// Round to nearest and halfway cases away from zero.
  case nearInf = 5
  /// Flag telling rescaling functions to pass `INT64_MIN`/`MAX` through
  /// unchanged, avoiding special cases for #AV_NOPTS_VALUE.
  ///
  /// Unlike other values of the enumeration `AVRounding`, this value is a
  /// bitmask that must be used in conjunction with another value of the
  /// enumeration through a bitwise OR, in order to set behavior for normal
  /// cases.
  ///
  ///     av_rescale_rnd(3, 1, 2, AV_ROUND_UP | AV_ROUND_PASS_MINMAX);
  ///     // Rescaling 3:
  ///     //     Calculating 3 * 1 / 2
  ///     //     3 / 2 is rounded up to 2
  ///     //     => 2
  ///
  ///     av_rescale_rnd(AV_NOPTS_VALUE, 1, 2, AV_ROUND_UP | AV_ROUND_PASS_MINMAX);
  ///     // Rescaling AV_NOPTS_VALUE:
  ///     //     AV_NOPTS_VALUE == INT64_MIN
  ///     //     AV_NOPTS_VALUE is passed through
  ///     //     => AV_NOPTS_VALUE
  case passMinMax = 8192

  internal var native: CFFmpeg.AVRounding {
    CFFmpeg.AVRounding(rawValue)
  }

  internal init(native: CFFmpeg.AVRounding) {
    guard let rounding = AVRounding(rawValue: native.rawValue) else {
      fatalError("Unknown rounding: \(native)")
    }
    self = rounding
  }

  public func union(_ other: AVRounding) -> AVRounding {
    if other != .passMinMax { return self }
    return AVRounding(rawValue: rawValue | other.rawValue)!
  }
}

public enum AVMath {

  /// Rescale a integer with specified rounding.
  ///
  /// The operation is mathematically equivalent to `a * b / c`, but writing that
  /// directly can overflow, and does not support different rounding methods.
  public static func rescale<T: BinaryInteger>(
    _ a: T, _ b: T, _ c: T,
    _ rounding: AVRounding = .inf
  ) -> Int64 {
    av_rescale_rnd(Int64(a), Int64(b), Int64(c), rounding.native)
  }

  /// Rescale a integer by 2 rational numbers with specified rounding.
  ///
  /// The operation is mathematically equivalent to `a * bq / cq`.
  public static func rescale<T: BinaryInteger>(
    _ a: T, _ b: AVRational, _ c: AVRational,
    _ rounding: AVRounding = .inf
  ) -> Int64 {
    av_rescale_q_rnd(Int64(a), b, c, rounding.native)
  }
}
