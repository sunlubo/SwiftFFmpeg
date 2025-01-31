//
//  AVBufferTests.swift
//  Tests
//
//  Created by sunlubo on 2018/8/14.
//

import XCTest

@testable import SwiftFFmpeg

final class AVBufferTests: XCTestCase {

  static var allTests = [
    ("test", test)
  ]

  func test() {
    let buf1 = AVBuffer(size: 100)
    XCTAssertEqual(buf1.size, 100)
    XCTAssertEqual(buf1.refCount, 1)
    XCTAssertEqual(buf1.isWritable, true)

    let buf2 = buf1.ref()!
    XCTAssertEqual(buf2.size, 100)
    XCTAssertEqual(buf2.refCount, 2)
    XCTAssertEqual(buf2.isWritable, false)
    XCTAssertEqual(buf1.size, 100)
    XCTAssertEqual(buf1.refCount, 2)
    XCTAssertEqual(buf1.isWritable, false)

    buf2.makeWritable()
    XCTAssertEqual(buf2.size, 100)
    XCTAssertEqual(buf2.refCount, 1)
    XCTAssertEqual(buf2.isWritable, true)
    XCTAssertEqual(buf1.size, 100)
    XCTAssertEqual(buf1.refCount, 1)
    XCTAssertEqual(buf1.isWritable, true)

    buf2.unref()
    XCTAssertEqual(buf2.native, nil)

    let buf3 = buf1.ref()!
    buf3.realloc(size: 200)
    XCTAssertEqual(buf1.size, 100)
    XCTAssertEqual(buf1.refCount, 1)
    XCTAssertEqual(buf1.isWritable, true)
    XCTAssertEqual(buf3.size, 200)
    XCTAssertEqual(buf3.refCount, 1)
    XCTAssertEqual(buf3.isWritable, true)

    buf1.unref()
    buf3.unref()
    XCTAssertEqual(buf1.native, nil)
    XCTAssertEqual(buf3.native, nil)
  }
}
