//
//  BlackWhiteXDeleteButton.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 17.01.24.
//

import SwiftUI

struct BlackWhiteXDeleteButton: View {
    
    // MARK: Properties
    static let dimension: CGFloat = 28.0
    
    let action: () -> Void

    // MARK: - Body
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "x.circle.fill")
                .resizable()
                .foregroundColor(.black)
                .padding(2)
                .background(
                    Circle()
                        .fill(.white)
                )
                .frame(width: Self.dimension,
                       height: Self.dimension)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    BlackWhiteXDeleteButton {
        print("Test")
    }
    .padding(30)
    .background(InputContainerBackgroundView())
}
