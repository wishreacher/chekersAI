//
//  PhotoSelectionView.swift
//  chekersAI
//
//  Created by Володимир on 21.06.2025.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct PhotoSelectionView: View {
    @ObservedObject var vm = ImageAnalysisViewModel()

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            if let image = vm.selectedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .overlay(
                            vm.drawDetections(detections: vm.boardDetections, imageFrame: vm.actualImageFrame, color: .blue)
                        )
                        .overlay(
                            vm.drawDetections(detections: vm.pieceDetections, imageFrame: vm.actualImageFrame, color: .red)
                        )
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        vm.updateImageFrames(containerSize: geo.size, image: image)
                                    }
                                    .onChange(of: vm.selectedImage) { _ in
                                        vm.updateImageFrames(containerSize: geo.size, image: image)
                                    }
                            }
                        )
                }
                .padding(.horizontal)
            }

            PhotosPicker(selection: $vm.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                Text("Select Photo")
                    .foregroundColor(.blue)
                    .padding()
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

            Spacer()
        }
        .padding()
    }
}

#Preview {
    PhotoSelectionView()
}
