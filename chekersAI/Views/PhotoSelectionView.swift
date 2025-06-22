//
//  PhotoSelectionView.swift
//  chekersAI
//
//  Created by Володимир on 21.06.2025.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct PhotoSelectionView: View {
    @StateObject var vm = ImageAnalysisViewModel()
    @State private var analysisCompleted = false // Track analysis state
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            if let image = vm.selectedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            if analysisCompleted {
                                vm.drawDetections(detections: vm.boardDetections, imageFrame: vm.actualImageFrame, color: .blue)
                                vm.drawDetections(detections: vm.pieceDetections, imageFrame: vm.actualImageFrame, color: .red)
                            }
                        }
                        .background {
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        print("Photo view appeared with container size: \(geo.size)")
                                        vm.updateImageFrames(containerSize: geo.size, image: image)
                                        DispatchQueue.main.async {
                                            print("Triggering analysis from onAppear for image: \(image.size)")
                                            vm.analyzeImage(image) {
                                                self.analysisCompleted = true
                                            }
                                        }
                                    }
                                    .onChange(of: geo.size) { _, newSize in
                                        print("Container size changed to: \(newSize)")
                                        vm.updateImageFrames(containerSize: newSize, image: image)
                                        DispatchQueue.main.async {
                                            print("Triggering analysis from container size change")
                                            vm.analyzeImage(image) {
                                                self.analysisCompleted = true
                                            }
                                        }
                                    }
                            }
                        }
                }
                .padding(.horizontal)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }
            
            PhotosPicker(selection: $vm.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                Text("Select Photo")
                    .foregroundColor(.blue)
                    .padding()
            }
            .onChange(of: vm.selectedPhotoItem) { _, newItem in
                DispatchQueue.main.async {
                    vm.selectedImage = nil
                    vm.boardDetections = []
                    vm.pieceDetections = []
                    vm.actualImageFrame = .zero
                    self.analysisCompleted = false
                    print("Photo selection cleared or new selection started")
                }
                
                guard let newItem = newItem else { return }
                
                Task {
                    do {
                        if let data = try await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            DispatchQueue.main.async {
                                print("Loaded new photo with size: \(uiImage.size)")
                                vm.selectedImage = uiImage
                            }
                        }
                    } catch {
                        print("Failed to load photo: \(error.localizedDescription)")
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
