//
//  AppDelegate.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 21.12.23.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Delegate
    func applicationDidFinishLaunching(_ notification: Notification) {
        styleTitleBar()
    }

    // MARK: - Helpers
    private func styleTitleBar() {
        guard let window = NSApplication.shared.windows.first else { return }

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isOpaque = false

        let backgroundColor = NSColor(Color(.backgroundGradient1)).cgColor
        window.standardWindowButton(.closeButton)?.superview?.wantsLayer = true
        window.standardWindowButton(.closeButton)?.superview?.layer?.backgroundColor = backgroundColor
    }
}
