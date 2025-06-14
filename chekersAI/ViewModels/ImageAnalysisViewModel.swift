//
//  ImageAnalysisViewModel.swift
//  chekersAI
//
//  Created by Володимир on 12.06.2025.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreML
import Vision

class ImageAnalysisViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var actualImageFrame: CGRect
    @Published var containerFrame: CGRect
    
    private var boardDetector: BoardDetector?
    private var pieceDetector: PieceDetector?
    
    var pieceDetections: [Detection] = []
    var boardDetections: [Detection] = []
    
    init (actualImageFrame: CGRect = .zero, containerFrame: CGRect = .zero) {
        self.actualImageFrame = actualImageFrame
        self.containerFrame = containerFrame
    }
    
    @ViewBuilder
    func drawDetections(detections: [Detection], imageFrame: CGRect, color: Color = .blue) -> some View {
        ForEach(detections) { detection in
            let rect = convertRect(from: detection.boundingBox, in: imageFrame)
            
            Rectangle()
                .stroke(color, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
            
            Text("\(detection.label) (\(Int(detection.confidence * 100))%)")
                .font(.caption)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.7))
                .position(x: rect.midX, y: rect.minY - 10)
        }
    }
    
    func analyzeImage(_ image: UIImage) {
        boardDetector = BoardDetector(image: image)
        pieceDetector = PieceDetector(image: image)
        
        boardDetections = boardDetector?.detect() ?? []
        pieceDetections = pieceDetector?.detect() ?? []
    }
    
    func updateImageFrames(containerSize: CGSize, image: UIImage) {
        containerFrame = CGRect(origin: .zero, size: containerSize)
        
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
        
        actualImageFrame = CGRect(origin: imageOffset, size: actualImageSize)
    }
}
