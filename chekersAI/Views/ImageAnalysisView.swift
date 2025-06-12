//
//  ContentView.swift
//  chekersAI
//
//  Created by Володимир on 08.06.2025.
//

import SwiftUI
import PhotosUI

struct ImageAnalysisView: View {
    @StateObject private var vm: ImageAnalysisViewModel = ImageAnalysisViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = vm.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onChange(of: proxy.size) {
                                    updateImageFrames(containerSize: proxy.size, image: image)
                                }
                                .onAppear {
                                    updateImageFrames(containerSize: proxy.size, image: image)
                                }
                        }
                    )
                    .overlay(
                        vm.drawDetections(detections: vm.detections, imageFrame: vm.actualImageFrame)
                    )
            }
            
            PhotosPicker(selection: $vm.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                Text("Select Photo")
                    .foregroundColor(.blue)
            }
            .onChange(of: vm.selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        vm.selectedImage = uiImage
                        vm.analyzeImage(uiImage)
                    }
                }
            }
            
            if let result = vm.analysisResult {
                Text("Analysis: \(result)")
                    .padding()
            }
        }
    }
    
    private func updateImageFrames(containerSize: CGSize, image: UIImage) {
        vm.containerFrame = CGRect(origin: .zero, size: containerSize)
        
        let imageSize = image.size
        let containerAspectRatio = containerSize.width / containerSize.height
        let imageAspectRatio = imageSize.width / imageSize.height
        
        var actualImageSize: CGSize
        var imageOffset: CGPoint
        
        if imageAspectRatio > containerAspectRatio {
            actualImageSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspectRatio
            )
            imageOffset = CGPoint(
                x: 0,
                y: (containerSize.height - actualImageSize.height) / 2
            )
        } else {
            actualImageSize = CGSize(
                width: containerSize.height * imageAspectRatio,
                height: containerSize.height
            )
            imageOffset = CGPoint(
                x: (containerSize.width - actualImageSize.width) / 2,
                y: 0
            )
        }
        
        vm.actualImageFrame = CGRect(origin: imageOffset, size: actualImageSize)
    }
}

#Preview {
    ImageAnalysisView()
}
