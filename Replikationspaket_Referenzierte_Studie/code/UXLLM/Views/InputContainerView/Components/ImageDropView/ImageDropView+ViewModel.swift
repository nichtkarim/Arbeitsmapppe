//
//  ImageDropView+ViewModel.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 18.12.23.
//

import SwiftUI

extension ImageDropView {
    
    @MainActor
    class ViewModel : ObservableObject {
        
        // MARK: - Properties
        @Published var isLoading: Bool = false
        @Published var isTargeted: Bool = false
        @Published var compressedImage: NSImage?
        
        let imageCompressor: ImageCompressor
        
        // MARK: - Init
        init(imageCompressor: ImageCompressor) {
            self.imageCompressor = imageCompressor
        }
        
        // MARK: - Interface
        func onDrop(providers: [NSItemProvider]) -> Bool {
            guard let provider = providers.first else { return false }
            _ = provider.loadDataRepresentation(for: .image) { data, error in
                if error == nil, let data {
                    Task {
                        await self.received(imageData: data)
                    }
                }
            }
            return true
        }
        
        func clearImage() {
            compressedImage = nil
        }
        
        // MARK: - Helper
        nonisolated
        private func received(imageData: Data) async {
            await setState(loadingActive: true)
            do {
                let compressedImageData = try await imageCompressor.resizeAndShrink(imageData: imageData,
                                                                                    size: Constants.imageCompressionSize)
                await setState(loadingActive: false, imageData: compressedImageData)
            } catch {
                print("Failed image compression with error: \(error.localizedDescription)")
                await setState(loadingActive: false)
            }
        }

        private func setState(loadingActive: Bool, imageData: Data? = nil) {
            isLoading = loadingActive
            compressedImage = imageData.flatMap({ NSImage(data: $0) })
        }
    }
}

// MARK: - Preview
extension ImageDropView.ViewModel {
    static func previewViewModelImageImageCompressorComponent() -> ImageCompressor {
        MockedImageCompressorService()
    }
}
