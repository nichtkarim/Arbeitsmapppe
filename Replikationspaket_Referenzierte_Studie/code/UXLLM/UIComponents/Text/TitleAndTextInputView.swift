//
//  TitleAndTextInputView.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 13.11.23.
//

import SwiftUI

struct TitleAndTextInputView: View {
    
    // MARK: - Properties
    let title: String
    let placeholder: String
    @Binding var text: String
    
    let onSave: (String) -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {
            TitledContainerView(title: title, accessoryQuestionMark: true) {
                TextEditorWithPlaceholder(placeholder: placeholder, text: $text)
                    .uxLLMBodyTextStyle()
                    .padding(16)
                    .glossyRoundedRectangleBackground(mode: .dark)
                    .onChange(of: text) {
                        onSave(text)
                    }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TitleAndTextInputView(title: "What is the app about?", 
                          placeholder: "A fitness tracking app...",
                          text: .constant("A fitness tracker app"),
                          onSave: { _ in })
    .padding(30)
    .background(InputContainerBackgroundView())
}
