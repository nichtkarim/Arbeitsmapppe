//
//  PromptGenerator.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 13.11.23.
//

import Foundation

struct BasicPromptGeneratorService: PromptGenerator {
    
    // MARK: - User Content
    func generateUserContent(with configuration: PromptConfiguration) -> String {
        var content =
        """
        I have an iOS app about: \(configuration.appOverview)
        The users's task in this app view is about: \(configuration.userTask).
        """
        
        if configuration.hasImage {
            content += """
            
            A screenshot of the app view is provided.
            """
        }
        
        if let sourceCode = configuration.sourceCode, 
            !sourceCode.trimFrontAndBackWhitespaces().isEmpty {
            content += """
            
            Below is the incomplete SwiftUI code for the app view.
            This code includes the view's user interface and a view model for logic handling.
            It may also include additional components like subviews, models, or preview code.
            
            \(sourceCode)
            """
        }
        
        return content
    }
    
    // MARK: - System Content
    func generateSystemContent() -> String {
        return """
        You are a UI/UX expert for mobile apps.
        Your task is to identify usability issues with the information you get for an app view. 
        An example of a usability issue could be: "Lack of visual feedback on user interactions."
        Respond using app domain language, you MUST not use technical terminology or mention code details.
        Enumerate the problems identified; add an empty paragraph after each enumeration; no preceding or following text.
        """
    }
}
