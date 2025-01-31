//
//  AVRationalTests.swift
//  Tests
//
//  Created by sunlubo on 2019/1/6.
//

import XCTest

@testable import SwiftFFmpeg

final class AVRationalTests: XCTestCase {

  static var allTests = [
    ("test", test)
  ]

  func test() {
    let r1 = AVRational(num: 1, den: 2)
    let r2 = AVRational(num: 2, den: 4)
    let r3 = AVRational(num: 2, den: 1)
    let r4 = AVRational(num: 1, den: 4)
    XCTAssertEqual(r1, r2)
    XCTAssertEqual(r1.toDouble, 0.5)
    XCTAssertEqual(r1.inverted, r3)

    XCTAssertEqual(r2 + r4, AVRational(num: 3, den: 4))
    XCTAssertEqual(r2 - r4, AVRational(num: 1, den: 4))
    XCTAssertEqual(r2 * r4, AVRational(num: 1, den: 8))
    XCTAssertEqual(r2 / r4, AVRational(num: 2, den: 1))
  }
}
