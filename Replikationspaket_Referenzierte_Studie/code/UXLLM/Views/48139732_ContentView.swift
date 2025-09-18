//
//  ContentView.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 09.11.23.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: ViewModel
    
    // MARK: - Init
    init(previewMode: Bool = false) {
        let viewModel = previewMode ? ViewModel.generatePreviewViewModel() : ViewModel.generateViewModel()
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            InputContainerView(viewModel: viewModel.inputContainerViewModel)
            
            StartLLMButtonView(isLoading: viewModel.isLoading) {
                viewModel.startGeneratingUsabilityIssues()
            }
            .offset(y: -BasicRoundButtonStyle.dimension/2)
            .zIndex(2.0)
            
            OutputContainerView(isLoading: viewModel.isLoading,
                                usabilityIssuesText: viewModel.llmOutput,
                                error: viewModel.errorText)
            .offset(y: -BasicRoundButtonStyle.dimension)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView(previewMode: true)
        .frame(height: 1100)
}
