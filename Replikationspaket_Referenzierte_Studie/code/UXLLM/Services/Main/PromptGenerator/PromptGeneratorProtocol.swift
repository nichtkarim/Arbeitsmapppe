//
//  PromptGeneratorProtocol.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 21.12.23.
//

import Foundation

struct PromptConfiguration {
    let appOverview: String
    let userTask: String
    let sourceCode: String?
    let hasImage: Bool
}

protocol PromptGenerator {
    func generateUserContent(with configuration: PromptConfiguration) -> String
    func generateSystemContent() -> String
}
