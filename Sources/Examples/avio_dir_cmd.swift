//
//  avio_dir_cmd.swift
//  SwiftFFmpegExamples
//
//  Created by sunlubo on 2019/1/9.
//

import SwiftFFmpeg

private func list_op() throws {
    if CommandLine.argc < 4 {
        print("Missing argument for list operation.")
        return
    }

    let input = CommandLine.arguments[3]
    let dirCtx = try AVIODirContext(url: input)
    defer {
        dirCtx.close()
    }

    print("TYPE SIZE NAME UID(GID) UGO MODIFIED ACCESSED STATUS_CHANGED")
    for entry in dirCtx {
        print("""
        \(entry.type) \(entry.size) \(entry.name) \
        \(entry.userId)(\(entry.groupId)) \
        \(entry.filemode) \
        \(entry.modificationTimestamp) \
        \(entry.accessTimestamp) \
        \(entry.statusChangeTimestamp)
        """)
    }
}

private func move_op() throws {
    if CommandLine.argc < 5 {
        print("Missing argument for move operation.")
        return
    }

    let src = CommandLine.arguments[3]
    let dst = CommandLine.arguments[4]
    try AVIO.move(src, dst)
}

private func del_op() throws {
    if CommandLine.argc < 4 {
        print("Missing argument for del operation.")
        return
    }

    let input = CommandLine.arguments[3]
    try AVIO.delete(input)
}

func avio_dir_cmd() throws {
    if CommandLine.argc < 3 {
        print("""
        Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) OPERATION entry1 [entry2]
            
        OPERATIONS:
          list      list content of the directory
          move      rename content in directory
          del       delete content in directory
        """)
        return
    }

    let op = CommandLine.arguments[2]
    switch op {
    case "list":
        try list_op()
    case "move":
        try move_op()
    case "del":
        try del_op()
    default:
        print("Invalid operation \(op)")
    }
}
