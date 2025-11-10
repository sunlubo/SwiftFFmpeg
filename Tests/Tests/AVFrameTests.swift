//
//  AVFrameTests.swift
//  Tests
//
//  Created by sunlubo on 2019/1/25.
//

import XCTest

@testable import SwiftFFmpeg

final class AVFrameTests: XCTestCase {

  static var allTests = [
    ("testAlloc", testAlloc),
    ("testRef", testRef),
    ("testUnref", testUnref),
  ]

  func testAlloc() {
    let f1 = AVFrame()
    f1.width = 1920
    f1.height = 1080
    f1.pixelFormat = .YUV420P

    XCTAssertNil(f1.buffer[0])
    XCTAssertFalse(f1.isWritable)

    XCTAssertNoThrow(try f1.allocBuffer())
    XCTAssertNotNil(f1.buffer[0])
    XCTAssertTrue(f1.isWritable)
  }

  func testRef() {
    let f1 = AVFrame()
    f1.width = 1920
    f1.height = 1080
    f1.pixelFormat = .YUV420P

    XCTAssertNoThrow(try f1.allocBuffer())

    let f2 = AVFrame()
    XCTAssertNoThrow(try f2.ref(from: f1))
    XCTAssertEqual(f1.width, f2.width)
    XCTAssertEqual(f1.height, f2.height)
    XCTAssertEqual(f1.pixelFormat, f2.pixelFormat)
    XCTAssertNotNil(f2.buffer[0])
    XCTAssertFalse(f1.isWritable)
    XCTAssertFalse(f2.isWritable)

    XCTAssertNoThrow(try f2.makeWritable())
    XCTAssertTrue(f2.isWritable)
  }

  func testUnref() {
    let f1 = AVFrame()
    f1.width = 1920
    f1.height = 1080
    f1.pixelFormat = .YUV420P

    XCTAssertNoThrow(try f1.allocBuffer())

    let f2 = AVFrame()
    XCTAssertNoThrow(try f2.ref(from: f1))

    f2.unref()
    XCTAssertTrue(f1.isWritable)
    XCTAssertFalse(f2.isWritable)
    XCTAssertEqual(f2.width, 0)
    XCTAssertEqual(f2.height, 0)
    XCTAssertEqual(f2.pixelFormat, .none)
    XCTAssertNil(f2.buffer[0])
  }

  func testMoveRef() {
    let f1 = AVFrame()
    f1.width = 1920
    f1.height = 1080
    f1.pixelFormat = .YUV420P

    XCTAssertNoThrow(try f1.allocBuffer())

    let f2 = AVFrame()
    f2.moveRef(from: f1)

    XCTAssertFalse(f1.isWritable)
    XCTAssertEqual(f1.width, 0)
    XCTAssertEqual(f1.height, 0)
    XCTAssertEqual(f1.pixelFormat, .none)
    XCTAssertNil(f1.buffer[0])

    XCTAssertTrue(f2.isWritable)
    XCTAssertEqual(f2.width, 1920)
    XCTAssertEqual(f2.height, 1080)
    XCTAssertEqual(f2.pixelFormat, .YUV420P)
    XCTAssertNotNil(f2.buffer[0])
  }

  func testClone() {
    let f1 = AVFrame()
    f1.width = 1920
    f1.height = 1080
    f1.pixelFormat = .YUV420P

    XCTAssertNoThrow(try f1.allocBuffer())

    let f2 = f1.clone()!
    XCTAssertEqual(f1.width, f2.width)
    XCTAssertEqual(f1.height, f2.height)
    XCTAssertEqual(f1.pixelFormat, f2.pixelFormat)
    XCTAssertNotNil(f2.buffer[0])
    XCTAssertFalse(f1.isWritable)
    XCTAssertFalse(f2.isWritable)
  }
}
