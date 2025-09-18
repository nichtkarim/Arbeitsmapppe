//
//  PersistingInputTextFieldsView.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 21.12.23.
//

import SwiftUI

struct PersistingInputTextFieldsView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: ViewModel = .init()
    @Binding var appOverview: String
    @Binding var userTask: String
    @Binding var sourceCode: String
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 40) {
            TitleAndTextInputView(title: "App Overview Input Title".localized(),
                                  placeholder: "App Overview Input Placeholder".localized(),
                                  text: $appOverview) { newValue in
                viewModel.persist(input: .appOverview, value: newValue)
            }
                                  .frame(height: 130)
            
            TitleAndTextInputView(title: "User Task Input Title".localized(),
                                  placeholder: "User Task Input Placeholder".localized(),
                                  text: $userTask) { newValue in
                viewModel.persist(input: .userTask, value: newValue)
            }
                                  .frame(height: 130)
            
            TitleAndTextInputView(title: "Source Code Input Title".localized(),
                                  placeholder: "Source Code Input Placeholder".localized(),
                                  text: $sourceCode) { newValue in
                viewModel.persist(input: .sourceCode, value: newValue)
            }
        }
        .onAppear {
            setupPersistedTextValues()
        }
    }
    
    // MARK: - Helper
    private func setupPersistedTextValues() {
        self.appOverview = viewModel.load(input: .appOverview)
        self.userTask = viewModel.load(input: .userTask)
        self.sourceCode = viewModel.load(input: .sourceCode)
    }
}

// MARK: - Preview
#Preview {
    PersistingInputTextFieldsView(appOverview: .constant("App Overview"),
                                  userTask: .constant("User Task"),
                                  sourceCode: .constant("Souce Code"))
    .padding(30)
    .background(InputContainerBackgroundView())
}
