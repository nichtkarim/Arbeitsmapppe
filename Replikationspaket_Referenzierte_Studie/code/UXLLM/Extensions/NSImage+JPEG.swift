//
//  NSImage+.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 18.12.23.
//

import SwiftUI

extension NSImage {
    func jpegData() -> Data? {
        let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
        return jpegData
    }
}
