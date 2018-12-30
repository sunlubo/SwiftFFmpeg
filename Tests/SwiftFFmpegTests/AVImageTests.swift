//
//  AVImageTests.swift
//  SwiftFFmpegTests
//
//  Created by sunlubo on 2018/8/5.
//

import XCTest
@testable import SwiftFFmpeg

final class AVImageTests: XCTestCase {

    static var allTests = [
        ("testBuf", testBuf),
        ("testLinesizes", testLinesizes),
        ("testTotalSize", testTotalSize)
    ]

    let width = 1080
    let height = 1920
    let pixFmt = AVPixelFormat.YUV420P

    var buf = [UnsafeMutablePointer<UInt8>?](repeating: nil, count: 4)
    var linesizes = [Int32](repeating: 0, count: 4)
    var totalSize = 0

    override func setUp() {
        super.setUp()

        totalSize = AVImage.alloc(
            data: &buf,
            linesizes: &linesizes,
            width: width,
            height: height,
            pixelFormat: pixFmt,
            align: 1
        )
    }

    override func tearDown() {
        super.tearDown()

        AVImage.free(&buf)
    }

    func testBuf() {
        XCTAssertNotNil(buf[0])
        XCTAssertNotNil(buf[1])
        XCTAssertNotNil(buf[2])
        XCTAssertNil(buf[3])

        var ptr = [UnsafeMutablePointer<UInt8>?](repeating: nil, count: 4)
        AVImage.fillPointers(&ptr, pixelFormat: pixFmt, height: height, ptr: buf.first!, linesizes: linesizes)
        XCTAssertEqual(buf, ptr)
    }

    func testLinesizes() {
        XCTAssertEqual(linesizes, [1080, 540, 540, 0])

        let lss = (0..<4).map({ Int32(AVImage.getLinesize(pixelFormat: pixFmt, width: width, plane: $0)) })
        XCTAssertEqual(linesizes, lss)

        var ptr = [Int32](repeating: 0, count: 4)
        AVImage.fillLinesizes(&ptr, pixelFormat: pixFmt, width: width)
        XCTAssertEqual(linesizes, ptr)
    }

    func testTotalSize() {
        let size = AVImage.getBufferSize(pixelFormat: pixFmt, width: width, height: height, align: 1)
        XCTAssertEqual(totalSize, size)
    }
}
