//
//  http_multiclient.swift
//  Examples
//
//  Created by sunlubo on 2019/1/13.
//

import Dispatch
import SwiftFFmpeg

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

private let queue = DispatchQueue(label: "http_client", attributes: .concurrent)

private func process_client(client: AVIOContext, input: String) throws {
  defer {
    print("Flushing client")
    client.flush()
    print("Closing client")
    client.close()
  }
  var resource = ""
  while !(try client.handshake()) {
    resource = try client.string(forKey: "resource")
    // check for strlen(resource) is necessary, because av_opt_get() may return empty string.
    if !resource.isEmpty {
      break
    }
  }
  print("resource=\(resource)")

  var replyCode = Int(AVError.httpNotFound.code)
  if resource.first == "/", resource.dropFirst() == input {
    replyCode = 200
  }
  try client.set(replyCode, forKey: "reply_code")
  print("Set reply code to \(replyCode).")

  while !(try client.handshake()) {
    // nop
  }

  print("Handshake performed.")
  if replyCode != 200 {
    return
  }
  print("Opening input file.")
  let input = try AVIOContext(url: input, flags: .read)
  defer {
    print("Closing input")
    input.close()
  }
  let bufSize = 1024
  let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: bufSize)
  buf.initialize(to: 0)
  defer {
    buf.deallocate()
  }
  var size = 0
  while true {
    do {
      size = try input.read(buf, size: bufSize)
    } catch let err as AVError where err == .eof {
      break
    } catch {
      print("Error reading from input: \(error).")
    }
    client.write(buf, size: size)
    client.flush()
  }
}

// This example will serve a file without decoding or demuxing it over http.
// Multiple clients can connect and will receive the same file.
func http_multiclient() throws {
  if CommandLine.argc < 4 {
    print(
      "Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) input http://hostname[:port]")
    return
  }

  AVLog.level = .trace
  try FFmpeg.networkInit()

  let input = CommandLine.arguments[2]
  let output = CommandLine.arguments[3]
  let server = try AVIOContext(url: output, flags: .write, options: ["listen": "2"])
  defer {
    server.close()
  }

  print("HTTP server start, you can use '\(output)/\(input)' to access it.")
  while true {
    let client = try server.accept()

    print("Accepted client")
    queue.async {
      do {
        try process_client(client: client, input: input)
      } catch {
        print(error)
      }
    }
  }
}
