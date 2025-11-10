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

extension AVRational: @retroactive Equatable {

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
}

public enum AVMath {
  /// Rescale a integer with specified rounding.
  ///
  /// The operation is mathematically equivalent to `a * b / c`, but writing that
  /// directly can overflow, and does not support different rounding methods.
  public static func rescale<T: BinaryInteger>(
    _ a: T, _ b: T, _ c: T,
    rounding: AVRounding = .inf,
    passMinMax: Bool = false
  ) -> Int64 {
    av_rescale_rnd(
      Int64(a), Int64(b), Int64(c),
      CFFmpeg.AVRounding(
        rawValue: passMinMax ? rounding.rawValue | AV_ROUND_PASS_MINMAX.rawValue : rounding.rawValue
      )
    )
  }

  /// Rescale a integer by 2 rational numbers with specified rounding.
  ///
  /// The operation is mathematically equivalent to `a * bq / cq`.
  public static func rescale<T: BinaryInteger>(
    _ a: T, _ b: AVRational, _ c: AVRational,
    rounding: AVRounding = .inf,
    passMinMax: Bool = false
  ) -> Int64 {
    av_rescale_q_rnd(
      Int64(a), b, c,
      CFFmpeg.AVRounding(
        rawValue: passMinMax ? rounding.rawValue | AV_ROUND_PASS_MINMAX.rawValue : rounding.rawValue
      )
    )
  }
}
