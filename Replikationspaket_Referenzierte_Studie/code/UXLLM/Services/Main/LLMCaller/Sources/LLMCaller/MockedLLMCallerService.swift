//
//  MockedLLMCallerService.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 18.12.23.
//

import Foundation

public struct MockedLLMCallerService: LLMCaller {
    
    // MARK: - Properties
    public var mockedResultText: String
    
    // MARK: - Init
    public init(mockedResultText: String) {
        self.mockedResultText = mockedResultText
    }
    
    // MARK: - Interface
    public func call(with configuration: LLMCallerConfiguration) async throws -> LLMResponse {
        try await Task.sleep(until: .now + .seconds(4), clock: .continuous)
        return LLMResponse(text: mockedResultText, tokens: 300)
    }
}
