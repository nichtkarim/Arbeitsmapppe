//
//  InputContainerBackgroundView.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 21.12.23.
//

import SwiftUI

struct InputContainerBackgroundView: View {
    
    // MARK: - Body
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(colors: [Color(.backgroundGradient1),
                                        Color(.backgroundGradient2)],
                               startPoint: .top,
                               endPoint: .bottom)
            )
            .clipShape(
                .rect(
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16
                )
            )
    }
}

// MARK: - Preview
#Preview {
    InputContainerBackgroundView()
}
