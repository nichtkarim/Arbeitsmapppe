//
//  ContentViewViewModelFactory.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 15.01.24.
//

import Foundation
import LLMCaller

struct ContentViewViewModelFactory {
    
    // MARK: - Interface
    static func generateConfiguredContentViewViewModel() -> ContentView.ViewModel {
        Constants.useMockedServices ? contentViewViewModelWithMockedServices() : contentViewViewModelWithServices()
    }
    
    // MARK: - Helper
    private static func contentViewViewModelWithServices() -> ContentView.ViewModel {
        .init(llmCaller: OpenAILLMCallerService(openAIKey: LocalConfiguration.openAIKey),
              promptGenerator: BasicPromptGeneratorService(),
              imageCompressor: TinfyImageCompressorNetworkService(tinyPNGKey: LocalConfiguration.tinyPNGKey)
        )
    }
    
    private static func contentViewViewModelWithMockedServices() -> ContentView.ViewModel {
        .init(llmCaller: MockedUsabilityIssuesLLMHelper.generateMockedLLM(),
              promptGenerator: BasicPromptGeneratorService(),
              imageCompressor: MockedImageCompressorService()
        )
    }
}
