//
//  ImageDropContainerView.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 19.12.23.
//

import SwiftUI

struct TitledContainerView<Content: View>: View {
    
    // MARK: - Properties
    let title: String
    let accessoryQuestionMark: Bool
    let content: Content

    // MARK: - Init
    init(title: String,
         accessoryQuestionMark: Bool = false,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.accessoryQuestionMark = accessoryQuestionMark
        self.content = content()
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            
            HStack(alignment: .center) {
                Text(title)
                    .uxLLMTitleTextStyle()
                    .multilineTextAlignment(.leading)
                    .leftAlignWithHStack()
                
                if accessoryQuestionMark {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(.tint))
                }
            }
            
            content
        }
    }
}

// MARK: - Preview
#Preview {
    TitledContainerView(title: "Test", accessoryQuestionMark: true) {
        Text("Hello World!")
    }
    .padding(30)
    .background(InputContainerBackgroundView())
}
