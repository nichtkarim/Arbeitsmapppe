//
//  PrimaryButtonStyle.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 13.11.23.
//

import SwiftUI

struct BasicRoundButtonStyle: ButtonStyle {
    
    // MARK: - Properties
    static let dimension: CGFloat = 84
    private let isLoading: Bool
    
    // MARK: - Init
    init(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    // MARK: - Body
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color(.tint))
            .uxLLMButtonTitleTextStyle()
            .lineLimit(1)
            .frame(width: Self.dimension,
                   height: Self.dimension)
            .background(
                Color(.basicRoundButton)
            )
            .overlay(
                Circle().stroke(Color(.basicRoundButtonColorStroke), lineWidth: 8)
            )
            .clipShape(
                Circle()
            )
            .blur(radius: isLoading ? 4.0 : 0.0)
            .shadow(color: .black.opacity(0.1), radius: 4.0, y: 2.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    Button {
        
    } label: {
        Text("Start")
    }
    .buttonStyle(BasicRoundButtonStyle(isLoading: false))
    .frame(width: 200, height: 200)
    .background( InputContainerBackgroundView() )
}
