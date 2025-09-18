//
//  PersistingInputTextFieldsView+ViewModel.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 21.12.23.
//

import SwiftUI

extension PersistingInputTextFieldsView {
    class ViewModel: ObservableObject {
        
        // MARK: - Properties
        enum TextualPersistableInput {
            case appOverview, userTask, sourceCode
            
            var userDefaultsKey: String {
                switch self {
                case .appOverview: return "appOverviewKey"
                case .userTask: return "userTaskKey"
                case .sourceCode: return "sourceCodeKey"
                }
            }
        }
        
        private let userDefaults = UserDefaults.standard
        
        // MARK: - Interface
        func persist(input: TextualPersistableInput, value: String) {
            userDefaults.setValue(value, forKey: input.userDefaultsKey)
        }
        
        func load(input: TextualPersistableInput) -> String {
            userDefaults.string(forKey: input.userDefaultsKey) ?? ""
        }
    }
}
