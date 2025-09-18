//
//  View+.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 13.11.23.
//

import SwiftUI

extension View {
    func leftAlignWithHStack() -> some View {
        HStack {
            self
            Spacer(minLength: 0)
        }
    }
    
    func rightAlignWithHStack() -> some View {
        HStack {
            Spacer(minLength: 0)
            self
        }
    }
    
    func botAlignWithVStack() -> some View {
        VStack {
            Spacer(minLength: 0)
            self
        }
    }
    
    func topAlignWithVStack() -> some View {
        VStack {
            self
            Spacer(minLength: 0)
        }
    }
}
