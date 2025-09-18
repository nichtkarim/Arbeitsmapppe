//
//  ImageCompressor.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 21.12.23.
//

import Foundation

protocol ImageCompressor {
    func resizeAndShrink(imageData: Data, size: CGSize) async throws -> Data
}
