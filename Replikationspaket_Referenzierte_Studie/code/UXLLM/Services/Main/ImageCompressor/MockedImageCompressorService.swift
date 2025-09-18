//
//  MockedImageCompressor.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 18.12.23.
//

import Foundation

struct MockedImageCompressorService: ImageCompressor {
    func resizeAndShrink(imageData: Data, size: CGSize) async throws -> Data {
        try await Task.sleep(until: .now + .seconds(3), clock: .continuous)
        return imageData
    }
}
