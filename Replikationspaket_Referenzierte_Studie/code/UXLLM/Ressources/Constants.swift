//
//  Constants.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 14.11.23.
//

import Foundation

struct Constants {
    static let useMockedServices: Bool = true
    
    static let openAILLM = OpenAILLM.gpt4TurboVision
    
    static let imageRatio = 2.16 // iPhone 13 Display
    static let imageCompressionSize = CGSize(width: 240, height: 518)
}
