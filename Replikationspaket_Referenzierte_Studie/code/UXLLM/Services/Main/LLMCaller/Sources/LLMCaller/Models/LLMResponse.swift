//
//  LLMResponse.swift
//  
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 17.01.24.
//

import Foundation

// Can be engineered to return more in the future
public struct LLMResponse {
    public let text: String
    public let tokens: Int
}
