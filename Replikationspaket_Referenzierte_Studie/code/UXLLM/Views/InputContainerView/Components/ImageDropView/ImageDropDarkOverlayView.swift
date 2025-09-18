//
//  ImageDropDarkOverlayView.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 17.01.24.
//

import SwiftUI

struct ImageDropDarkOverlayView: View {
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
            
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                Text("Image Drop View Targeted Text".localized())
                    .uxLLMTitleTextStyle()
            }
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Preview
#Preview {
    ImageDropDarkOverlayView()
        .padding(30)
        .background(InputContainerBackgroundView())
}
