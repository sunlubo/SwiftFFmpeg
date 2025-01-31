//
//  bsf.swift
//  Examples
//
//  Created by sunlubo on 2019/1/18.
//

import SwiftFFmpeg

func bsf() throws {
  for filter in AVBitStreamFilter.supportedFilters {
    print("\(filter.name): \(filter.supportedCodecIds)")
  }
}
