//
//  UsabilityIssuePresentationView.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 13.11.23.
//

import SwiftUI

struct UsabilityIssuePresentationView: View {
    
    // MARK: - Properties
    let usabilityIssuesText: String
    
    // MARK: - Body
    var body: some View {
        VStack {
            
            Text("Usability Issues Presentation Title".localized())
                .uxLLMTitleTextStyle()
                .leftAlignWithHStack()
            
            ScrollView(showsIndicators: false) {
                Text(usabilityIssuesText)
                    .foregroundStyle(Color(.tint))
                    .uxLLMBodyTextStyle()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Yet a hidden feature
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(usabilityIssuesText, forType: .string)
        }
    }
}

// MARK: - Preview
#Preview {
    UsabilityIssuePresentationView(usabilityIssuesText: MockedUsabilityIssuesLLMHelper.mockedUsabilityIssues)
        .padding()
        .background(
            OutputContainerBackgroundView(adjustContrastForText: true)
        )
}
