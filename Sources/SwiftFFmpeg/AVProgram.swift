//
//  AVProgram.swift
//
//
//  Created by LiuYi on 2022/6/22.
//

import CFFmpeg

typealias CAVProgram = CFFmpeg.AVProgram

public enum AVProgramMetaKey: String {
  case serviceProvider = "service_provider"
  case serviceName = "service_name"
}

public final class AVProgram {
  var native: UnsafeMutablePointer<CAVProgram>!

  init(native: UnsafeMutablePointer<CAVProgram>) {
    self.native = native
  }

  public var pmtPid: Int32 {
    get { native.pointee.pmt_pid }
    set { native.pointee.pmt_pid = newValue }
  }

  public var programNum: Int32 {
    get { native.pointee.program_num }
    set { native.pointee.program_num = newValue }
  }

  public var pcrPid: Int32 {
    get { native.pointee.pcr_pid }
    set { native.pointee.pcr_pid = newValue }
  }

  /// Accesses the instance referenced by this pointer.
  ///
  /// When reading from the `pointee` property, the instance referenced by this
  /// pointer must already be initialized. When `pointee` is used as the left
  /// side of an assignment, the instance must be initialized or this
  /// pointer's `Pointee` type must be a trivial type.
  ///
  /// Do not assign an instance of a nontrivial type through `pointee` to
  /// uninitialized memory. Instead, use an initializing method, such as
  /// `initialize(repeating:count:)`.
  public var id: Int32 {
    get { native.pointee.id }
    set { native.pointee.id = newValue }
  }

  public var streamCount: Int {
    get { Int(native.pointee.nb_stream_indexes) }
    set { native.pointee.nb_stream_indexes = UInt32(newValue) }
  }

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

  public var streamIndexs: [UInt32] {
    get {
      var list = [UInt32]()
      for i in 0 ..< streamCount {
        let streamIndex = native.pointee.stream_index.advanced(by: i).pointee
        list.append(streamIndex)
      }
      return list
    }
  }
}

extension AVFormatContext {
  /// The number of programs in the file.

  public var programCount: Int {
    Int(native.pointee.nb_programs)
  }

  public var programs: [AVProgram] {
    var list = [AVProgram]()
    for i in 0 ..< programCount {
      let program = native.pointee.programs.advanced(by: i).pointee!
      list.append(AVProgram(native: program))
    }
    return list
  }
}
