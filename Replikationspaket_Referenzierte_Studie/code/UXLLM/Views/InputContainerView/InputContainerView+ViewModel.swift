//
//  InputContainerView+ViewModel.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 21.12.23.
//

import SwiftUI

extension InputContainerView {
    class ViewModel: ObservableObject {
        
        // MARK: - Properties
        struct InputConfiguration {
            var appOverview: String = ""
            var userTask: String = ""
            var sourceCode: String = ""
            var nsImage: NSImage? = nil
            let llmModel: OpenAILLM = Constants.openAILLM
        }
    
        @Published var inputConfiguration: InputConfiguration = .init()
        let imageCompressor: ImageCompressor
            
        // MARK: - Init
        init(inputConfiguration: InputConfiguration = .init(),
             imageCompressor: ImageCompressor) {
            self.inputConfiguration = inputConfiguration
            self.imageCompressor = imageCompressor
        }
    }
}

// MARK: - Preview
extension InputContainerView.ViewModel {
    static func previewViewModel() -> InputContainerView.ViewModel {
        .init(imageCompressor: MockedImageCompressorService())
    }
}
