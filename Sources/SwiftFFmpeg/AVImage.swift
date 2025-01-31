//
//  AVImage.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/12.
//

import CFFmpeg

public final class AVImage {
  public let data: UnsafeMutableBufferPointer<UnsafeMutablePointer<UInt8>?>
  public let linesizes: UnsafeMutableBufferPointer<Int32>
  public let size: Int
  public let width: Int
  public let height: Int
  public let pixelFormat: AVPixelFormat
  var owned: Bool = false

  /// Allocate an image with size and pixel format.
  ///
  /// - Parameters:
  ///   - width: image width
  ///   - height: image height
  ///   - pixelFormat: image pixel format
  ///   - align: the value to use for buffer size alignment, e.g. 1(no alignment), 16, 32, 64
  public init(width: Int, height: Int, pixelFormat: AVPixelFormat, align: Int = 1) {
    let data = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>.allocate(capacity: 4)
    data.initialize(to: nil)

    let linesizes = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
    linesizes.initialize(to: 0)

    let ret = av_image_alloc(
      data, linesizes, Int32(width), Int32(height), pixelFormat, Int32(align)
    )
    guard ret >= 0 else {
      abort("av_image_alloc: \(AVError(code: ret))")
    }

    self.data = UnsafeMutableBufferPointer(start: data, count: 4)
    self.linesizes = UnsafeMutableBufferPointer(start: linesizes, count: 4)
    self.size = Int(ret)
    self.width = width
    self.height = height
    self.pixelFormat = pixelFormat
    self.owned = true
  }

  /// Create an image from the given frame.
  public init(frame: AVFrame) {
    precondition(frame.pixelFormat != .none)

    let data = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>.allocate(capacity: 4)
    data.initialize(to: nil)
    data.update(from: frame.data.baseAddress!, count: 4)

    let linesizes = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
    linesizes.initialize(to: 0)
    linesizes.update(from: frame.linesize.baseAddress!, count: 4)

    self.data = UnsafeMutableBufferPointer(start: data, count: 4)
    self.size = frame.buffer.reduce(0) { $0 + ($1?.size ?? 0) }
    self.linesizes = UnsafeMutableBufferPointer(start: linesizes, count: 4)
    self.width = frame.width
    self.height = frame.height
    self.pixelFormat = frame.pixelFormat
    self.owned = false
  }

  deinit {
    if owned {
      av_freep(data.baseAddress)
    }
    data.deallocate()
    linesizes.deallocate()
  }

  /// Copy image from the given pixel buffer.
  public func copy(
    from buffer: UnsafeMutablePointer<UnsafePointer<UInt8>?>,
    linesizes: UnsafePointer<Int32>
  ) {
    av_image_copy(
      data.baseAddress,
      self.linesizes.baseAddress,
      buffer,
      linesizes,
      pixelFormat,
      Int32(width),
      Int32(height)
    )
  }

  /// Copy image from the given frame.
  public func copy(from frame: AVFrame) {
    frame.data.withMemoryRebound(to: UnsafePointer<UInt8>?.self) { ptr in
      copy(from: ptr.baseAddress!, linesizes: frame.linesize.baseAddress!)
    }
  }

  /// Reformat image using the given `SwsContext`.
  ///
  /// - Returns: the height of the output slice
  /// - Throws: AVError
  @discardableResult
  public func reformat(using context: SwsContext, to image: AVImage) throws -> Int {
    try data.withMemoryRebound(to: UnsafePointer<UInt8>?.self) { ptr in
      try context.scale(
        src: ptr.baseAddress!,
        srcStride: linesizes.baseAddress!,
        srcSliceY: 0,
        srcSliceHeight: height,
        dst: image.data.baseAddress!,
        dstStride: image.linesizes.baseAddress!
      )
    }
  }
}

extension AVImage {

  /// Compute the size of an image line with format and width for the plane.
  ///
  /// - Returns: the computed size in bytes
  /// - Throws: AVError
  public static func getLinesize(pixelFormat: AVPixelFormat, width: Int, plane: Int) throws -> Int {
    let ret = av_image_get_linesize(pixelFormat, Int32(width), Int32(plane))
    try throwIfFail(ret)
    return Int(ret)
  }

  /// Fill plane linesizes for an image with pixel format and width.
  ///
  /// - Throws: AVError
  public static func fillLinesizes(
    _ linesizes: UnsafeMutablePointer<Int32>,
    pixelFormat: AVPixelFormat,
    width: Int
  ) throws {
    try throwIfFail(av_image_fill_linesizes(linesizes, pixelFormat, Int32(width)))
  }

  /// Fill plane data pointers for an image with pixel format and height.
  ///
  /// - Parameters:
  ///   - data: pointers array to be filled with the pointer for each image plane
  ///   - pixelFormat: the pixel format of the image
  ///   - height: the height of the image
  ///   - buffer: the pointer to a buffer which will contain the image
  ///   - linesizes: the array containing the linesize for each plane, should be filled by
  ///     `fillLinesizes(_:pixelFormat:width:)`
  /// - Returns: the size in bytes required for the image buffer
  /// - Throws: AVError
  @discardableResult
  public static func fillPointers(
    _ data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
    pixelFormat: AVPixelFormat,
    height: Int,
    buffer: UnsafeMutablePointer<UInt8>?,
    linesizes: UnsafePointer<Int32>?
  ) throws -> Int {
    let ret = av_image_fill_pointers(data, pixelFormat, Int32(height), buffer, linesizes)
    try throwIfFail(ret)
    return Int(ret)
  }

  /// Return the size in bytes of the amount of data required to store an image with the given parameters.
  ///
  /// - Parameters:
  ///   - pixelFormat: the pixel format of the image
  ///   - width: the width of the image in pixels
  ///   - height: the height of the image in pixels
  ///   - align: the assumed linesize alignment
  /// - Returns: the buffer size in bytes
  /// - Throws: AVError
  public static func getBufferSize(
    pixelFormat: AVPixelFormat,
    width: Int,
    height: Int,
    align: Int = 1
  ) throws -> Int {
    let ret = av_image_get_buffer_size(pixelFormat, Int32(width), Int32(height), Int32(align))
    try throwIfFail(ret)
    return Int(ret)
  }

  /// Copy image data from an frame into a buffer.
  ///
  /// - Parameters:
  ///   - frame: the source frame
  ///   - buffer: a buffer into which picture data will be copied
  ///   - size: the size in bytes of dst
  ///   - align: the assumed linesize alignment for dst
  /// - Returns: the number of bytes written to dst
  /// - Throws: AVError
  @discardableResult
  public static func copyImageData(
    from frame: AVFrame,
    to buffer: UnsafeMutablePointer<UInt8>,
    size: Int,
    align: Int = 1
  ) throws -> Int {
    try frame.data.withMemoryRebound(to: UnsafePointer<UInt8>?.self) { ptr -> Int in
      let ret = av_image_copy_to_buffer(
        buffer,
        Int32(size),
        ptr.baseAddress,
        frame.linesize.baseAddress!,
        frame.pixelFormat,
        Int32(frame.width),
        Int32(frame.height),
        Int32(align)
      )
      try throwIfFail(ret)
      return Int(ret)
    }
  }

  /// Create a pixel buffer and copy image data from an frame into the buffer.
  ///
  /// - Parameters:
  ///   - frame: the source frame
  ///   - align: the assumed linesize alignment for dst
  /// - Returns: a buffer into which picture data will be copied
  /// - Throws: AVError
  public static func makePixelBuffer(
    from frame: AVFrame,
    align: Int = 1
  ) throws -> UnsafeMutableBufferPointer<UInt8> {
    let size = try getBufferSize(
      pixelFormat: frame.pixelFormat,
      width: frame.width,
      height: frame.height,
      align: align
    )
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
    buffer.initialize(to: 0)
    let written = try copyImageData(from: frame, to: buffer, size: size, align: align)
    return UnsafeMutableBufferPointer(start: buffer, count: written)
  }
}
