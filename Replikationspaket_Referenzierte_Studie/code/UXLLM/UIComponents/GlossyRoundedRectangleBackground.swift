//
//  BlurredBackground.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 19.12.23.
//

import SwiftUI

struct GlossyRoundedRectangleBackgroundView: View {
    
    // MARK: - Properties
    enum Mode {
        case light, dark
            
        var associatedColor: Color {
            switch self {
            case .light: return .white.opacity(0.3)
            case .dark: return .black.opacity(0.16)
            }
        }
    }

    let mode: Mode
    
    // MARK: - Body
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(mode.associatedColor)
            .shadow(color: .black.opacity(0.3), radius: 2.0, y: 2.0)
    }
}

// MARK: - Modifier
extension View {
    func glossyRoundedRectangleBackground(mode: GlossyRoundedRectangleBackgroundView.Mode) -> some View {
        self.background(GlossyRoundedRectangleBackgroundView(mode: mode))
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello, World!")
                .padding(100)
                .glossyRoundedRectangleBackground(mode: .light)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(colors: [.blue, .orange], startPoint: .top, endPoint: .bottom))
    }
}
