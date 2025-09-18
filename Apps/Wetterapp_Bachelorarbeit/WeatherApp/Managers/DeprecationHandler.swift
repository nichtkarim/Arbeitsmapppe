import SwiftUI

// MARK: - Deprecation Suppression
// This file contains workarounds for iOS 17.0 deprecation warnings
// TODO: Migrate to new APIs when dropping support for iOS 16.x

#if compiler(>=5.9) // Xcode 15+
// Suppress specific deprecation warnings for controlled legacy API usage
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#endif

// MARK: - Legacy API Usage Notes
/*
 Current deprecated APIs in use:
 
 1. Map(coordinateRegion:annotationItems:annotationContent:) 
    - Deprecated in iOS 17.0
    - Replacement: Map with MapContentBuilder
    - Used in: MapView.swift
 
 2. MapAnnotation
    - Deprecated in iOS 17.0  
    - Replacement: Annotation
    - Used in: MapView.swift
 
 3. onChange(of:perform:)
    - Deprecated in iOS 17.0
    - Replacement: onChange(of:initial:_:)
    - Handled by: ViewExtensions.onChangeCompatible()
 
 Migration Plan:
 - Phase 1: Suppress warnings for stable release
 - Phase 2: Implement availability checks
 - Phase 3: Full migration to iOS 17+ APIs
*/

#if compiler(>=5.9)
#pragma clang diagnostic pop
#endif
