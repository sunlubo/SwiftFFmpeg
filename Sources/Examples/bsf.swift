//
//  bsf.swift
//  SwiftFFmpegExamples
//
//  Created by sunlubo on 2019/1/18.
//

import SwiftFFmpeg

func bsf() throws {
    for filter in BitStreamFilter.supportedFilters {
        print("\(filter.name): \(filter.codecIds ?? [])")
    }
}
