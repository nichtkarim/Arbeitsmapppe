//
//  ImageDropView.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 13.11.23.
//

import SwiftUI

struct ImageDropView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: ViewModel
    @Binding var nsImage: NSImage?
    
    private let width: CGFloat = 180
    private let rectangleCornerRadius: CGFloat = 25.0
    
    // MARK: - Init 
    init(imageCompressor: ImageCompressor, nsImage: Binding<NSImage?>) {
        self._viewModel = StateObject(wrappedValue: ViewModel(imageCompressor: imageCompressor))
        self._nsImage = nsImage
    }
    
    // MARK: - Body Content
    var body: some View {
        content
            .frame(width: width,
                   height: width * Constants.imageRatio)
            .background(
                strokedBackgroundRectangleIfNeeded
            )
            .overlay {
                darkOverlayIfTargeted
            }
            .clipShape(
                RoundedRectangle(cornerRadius: rectangleCornerRadius)
            )
            .overlay {
                deleteButtonIfNeeded
            }
            .onDrop(of: [.image],
                    isTargeted: $viewModel.isTargeted,
                    perform: { providers in
                viewModel.onDrop(providers: providers)
            })
            .animation(.default, value: viewModel.isTargeted)
            .onChange(of: viewModel.compressedImage) {
                self.nsImage = viewModel.compressedImage
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if let nsImage {
            generateImageContent(image: nsImage)
        } else if viewModel.isLoading {
            loadingContent
        } else {
            idleContent
        }
    }
    
    private func generateImageContent(image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: rectangleCornerRadius))
    }
    
    @ViewBuilder
    private var loadingContent: some View {
        ProgressView()
            .colorInvert() // MacOS white color workaround
            .brightness(1)
    }
    
    @ViewBuilder
    private var idleContent: some View {
        Image(systemName: "photo.badge.plus")
            .font(.system(size: 40))
            .foregroundColor(Color(.tint))
            .opacity(viewModel.isTargeted ? 0.0 : 1.0)
    }
    
    // MARK: - Body Helpers
    private var strokedBackgroundRectangleIfNeeded: some View {
        RoundedRectangle(cornerRadius: rectangleCornerRadius)
            .strokeBorder(Color.white,
                          style: StrokeStyle(lineWidth: nsImage == nil ? 4 : 0,
                                             dash: [10]))
    }
    
    @ViewBuilder
    private var darkOverlayIfTargeted: some View {
        if viewModel.isTargeted {
            ImageDropDarkOverlayView()
        }
    }
    
    @ViewBuilder
    private var deleteButtonIfNeeded: some View {
        if nsImage != nil {
            BlackWhiteXDeleteButton {
                viewModel.clearImage()
            }
            .topAlignWithVStack()
            .rightAlignWithHStack()
            .offset(x: BlackWhiteXDeleteButton.dimension / 2,
                    y: -BlackWhiteXDeleteButton.dimension / 2)
        }
    }
}

// MARK: - Preview
#Preview {
    ImageDropView(imageCompressor: ImageDropView.ViewModel.previewViewModelImageImageCompressorComponent(),
                  nsImage: .constant(.init()))
    .padding(30)
    .background(InputContainerBackgroundView())
}
