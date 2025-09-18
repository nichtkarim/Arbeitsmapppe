//
//  OpenAIModel.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 18.12.23.
//

import Foundation

enum OpenAILLM: Identifiable, CaseIterable {
    case gpt3Turbo, gpt4Turbo, gpt4TurboVision
    
    var id: String { self.identifier }
    
    fileprivate var identifier: String {
        switch self {
        case .gpt3Turbo: return "gpt-3.5-turbo-1106" // $0.0010 / $0.0020 per 1k tokens
        case .gpt4Turbo: return "gpt-4-1106-preview" // $0.01 Input / $0.03 Output per 1k tokens
        case .gpt4TurboVision: return "gpt-4-vision-preview"
        }
    }
}
