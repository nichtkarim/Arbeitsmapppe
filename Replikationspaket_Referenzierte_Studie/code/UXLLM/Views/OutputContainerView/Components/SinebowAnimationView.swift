//
//  SinebowAnimation.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 19.12.23.
//

import SwiftUI

struct SinebowAnimationView: View {
    
    // MARK: - Properties
    @State private var startTime = Date.now
    
    let shaderSineWidth: CGFloat
    let shaderSineHeight: CGFloat
    let timeMultiplier: CGFloat
    
    // MARK: - Body
    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = startTime.distance(to: timeline.date)

            Rectangle()
                .visualEffect { content, proxy in
                    content
                        .colorEffect(
                            ShaderLibrary.sinebow(
                                .float2(.init(width: shaderSineWidth,
                                              height: shaderSineHeight)),
                                .float(elapsedTime * timeMultiplier)
                            )
                        )
                }
        }
    }
}

// MARK: - Preview
#Preview {
    SinebowAnimationView(shaderSineWidth: 500,
                         shaderSineHeight: 400,
                         timeMultiplier: 2.0)
}
