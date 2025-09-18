//
//  LLMCaller.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 21.12.23.
//

import Foundation

public struct LLMCallerConfiguration {
    public let modelId: String
    public let base64EncodedImage: String?
    public let systemContent: String
    public let userContent: String
    
    public init(modelId: String,
                base64EncodedImage: String?,
                systemContent: String,
                userContent: String) {
        self.modelId = modelId
        self.base64EncodedImage = base64EncodedImage
        self.systemContent = systemContent
        self.userContent = userContent
    }
}

public protocol LLMCaller {
    func call(with configuration: LLMCallerConfiguration) async throws -> LLMResponse
}
