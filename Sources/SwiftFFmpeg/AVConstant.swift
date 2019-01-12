//
//  AVConstant.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/10.
//

import CFFmpeg

public enum AVConstant {
    public static let inputBufferPaddingSize = Int(AV_INPUT_BUFFER_PADDING_SIZE)
    public static let dataPointersNumber = Int(AV_NUM_DATA_POINTERS)
}
