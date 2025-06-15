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
//            if let image = vm.selectedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxWidth: .infinity, maxHeight: 300)
//                    .background(
//                        GeometryReader { proxy in
//                            Color.clear
//                                .onChange(of: proxy.size) {
//                                    vm.updateImageFrames(containerSize: proxy.size, image: image)
//                                }
//                                .onAppear {
//                                    vm.updateImageFrames(containerSize: proxy.size, image: image)
//                                }
//                        }
//                    )
//                
//                    .overlay(
//                        ZStack {
//                            vm.drawDetections(detections: vm.pieceDetections, imageFrame: vm.actualImageFrame)
//                            vm.drawDetections(detections: vm.boardDetections, imageFrame: vm.actualImageFrame)
//                        }
//                    )
//            }
            if let image = vm.selectedImage {
                GeometryReader { geometry in
                    Image(uiImage: vm.selectedImage!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .overlay(
                            vm.drawDetections(detections: vm.boardDetections, imageFrame: vm.actualImageFrame, color: .blue)
                        )
                        .overlay(
                            vm.drawDetections(detections: vm.pieceDetections, imageFrame: vm.actualImageFrame, color: .red)
                        )
                        .onAppear {
                            vm.updateImageFrames(containerSize: geometry.size, image: vm.selectedImage!)
                        }
                        .onChange(of: vm.selectedImage) { _ in
                            vm.updateImageFrames(containerSize: geometry.size, image: vm.selectedImage!)
                        }
                }
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
        }
    }
}

#Preview {
    ImageAnalysisView()
}
