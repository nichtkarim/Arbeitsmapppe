//
//  OutputContainerView.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 21.12.23.
//

import SwiftUI

struct OutputContainerView: View {
    
    // MARK: - Properties
    let isLoading: Bool
    let usabilityIssuesText: String?
    let error: String?
    
    private var shouldShow: Bool {
        isLoading || usabilityIssuesText != nil || error != nil
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            if isLoading {
                SinebowAnimationView(shaderSineWidth: 280,
                                     shaderSineHeight: 100,
                                     timeMultiplier: 1.5)
                .frame(height: 220)
                .padding(.top, 80)
            } else if let usabilityIssuesText {
                UsabilityIssuePresentationView(usabilityIssuesText: usabilityIssuesText)
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
            } else if let error {
                ErrorView(error: error)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
            }
            
            Spacer()
        }
        .padding(.bottom, 10)
        .frame(width: 700)
        .frame(minHeight: 220) // Necessary for non buggy scale effect animation
        .background(OutputContainerBackgroundView(adjustContrastForText: !isLoading))
        .scaleEffect(y: shouldShow ? 1 : 0, anchor: .top)
        .animation(.easeInOut(duration: 0.6) , value: shouldShow)
    }
}

// MARK: - Preview
#Preview {
    OutputContainerView(isLoading: true,
                        usabilityIssuesText: MockedUsabilityIssuesLLMHelper.mockedUsabilityIssues,
                        error: nil)
    .frame(width: 800, height: 500)
}
