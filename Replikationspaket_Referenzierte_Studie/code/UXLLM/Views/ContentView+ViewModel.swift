//
//  ContentView+ViewModel.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 18.12.23.
//

import SwiftUI
import LLMCaller

extension ContentView {
    class ViewModel: ObservableObject {
        
        // MARK: - Properties
        @Published var llmOutput: String? = nil
        @Published var errorText: String? = nil
        @Published var isLoading: Bool = false
        
        let inputContainerViewModel: InputContainerView.ViewModel
        
        let llmCaller: LLMCaller
        let promptGenerator: PromptGenerator
        
        // MARK: - Init
        init(llmCaller: LLMCaller,
             promptGenerator: PromptGenerator,
             imageCompressor: ImageCompressor) {
            self.llmCaller = llmCaller
            self.promptGenerator = promptGenerator
            self.inputContainerViewModel = .init(imageCompressor: imageCompressor)
        }
        
        // MARK: - Interface
        func startGeneratingUsabilityIssues() {
            Task {
                do {
                    await changePresentationState(loadingActive: true)
                    let inputConfiguration = inputContainerViewModel.inputConfiguration
                    let base64EncodedImage = inputConfiguration.nsImage?.jpegData()?.base64EncodedString()
                    let promptConfiguration = inputConfiguration.generatePromptConfiguration()
                    let llmResponse = try await llmCaller.call(with: .init(modelId: inputConfiguration.llmModel.id,
                                                                           base64EncodedImage: base64EncodedImage,
                                                                           systemContent: promptGenerator.generateSystemContent(),
                                                                           userContent: promptGenerator.generateUserContent(with: promptConfiguration)))
                    await changePresentationState(loadingActive: false, llmOutput: llmResponse.text)
                } catch {
                    await changePresentationState(loadingActive: false,
                                                  errorText: (error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
                    
                }
            }
        }
        
        // MARK: - Helper
        @MainActor
        private func changePresentationState(loadingActive: Bool,
                                             llmOutput: String? = nil,
                                             errorText: String? = nil) {
            self.llmOutput = llmOutput
            self.errorText = errorText
            
            withAnimation(Animation.easeInOut(duration: 0.6)) {
                self.isLoading = loadingActive
            }
        }
    }
}

// MARK: - Initialize State Object View Model 
extension ContentView.ViewModel {
    static func generateViewModel() -> ContentView.ViewModel {
        ContentViewViewModelFactory.generateConfiguredContentViewViewModel()
    }
    
    static func generatePreviewViewModel() -> ContentView.ViewModel {
        .init(llmCaller: MockedUsabilityIssuesLLMHelper.generateMockedLLM(),
              promptGenerator: BasicPromptGeneratorService(),
              imageCompressor: MockedImageCompressorService())
    }
}

// MARK: - Extensions
private extension InputContainerView.ViewModel.InputConfiguration {
    func generatePromptConfiguration() -> PromptConfiguration {
        .init(appOverview: appOverview, userTask: userTask, sourceCode: sourceCode, hasImage: nsImage == nil)
    }
}
