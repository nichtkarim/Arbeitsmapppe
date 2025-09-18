//
//  UXLLMApp.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 09.11.23.
//

import SwiftUI

@main
struct UXLLMApp: App {
    
    // MARK: - Properties
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(TransparentWindow())
        }
    }
}
