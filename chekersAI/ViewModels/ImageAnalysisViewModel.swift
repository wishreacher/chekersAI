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

class ImageAnalysisViewModel: NSObject, ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var actualImageFrame: CGRect
    @Published var containerFrame: CGRect
    @Published var currentPlayer: Player = .black
    @Published var boardDetections: [Detection] = []
    @Published var pieceDetections: [Detection] = []
    
    private var boardDetector: BoardDetector?
    private var pieceDetector: PieceDetector?
    
    init(actualImageFrame: CGRect = .zero, containerFrame: CGRect = .zero) {
        self.actualImageFrame = actualImageFrame
        self.containerFrame = containerFrame
        super.init()
    }
    
    @ViewBuilder
    func drawDetections(detections: [Detection], imageFrame: CGRect, color: Color = .blue) -> some View {
        //print("Drawing \(detections.count) detections with imageFrame: \(imageFrame)")
        ForEach(detections) { detection in
            let rect = convertRect(from: detection.boundingBox, in: imageFrame)
            //print("Detection: \(detection.label), boundingBox: \(detection.boundingBox), converted: \(rect)")
            
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
    
    func analyzeImage(_ image: UIImage, completion: @escaping () -> Void) {
        print("Starting analysis for image with size: \(image.size), actualImageFrame: \(actualImageFrame)")
        
        // Reset state
        DispatchQueue.main.async { [weak self] in
            self?.boardDetections = []
            self?.pieceDetections = []
            self?.boardDetector = nil
            self?.pieceDetector = nil
        }
        
        // Create new detectors
        boardDetector = BoardDetector(image: image)
        pieceDetector = PieceDetector(image: image)
        
        // Reset detectors
        boardDetector?.reset()
        pieceDetector?.reset()
        
        // Perform detections
        let newBoardDetections = boardDetector?.detect() ?? []
        let newPieceDetections = pieceDetector?.detect() ?? []
        
        // Update detections on main queue
        DispatchQueue.main.async { [weak self] in
            self?.boardDetections = newBoardDetections
            self?.pieceDetections = newPieceDetections
            print("Updated detections: Board: \(newBoardDetections.count), Pieces: \(newPieceDetections.count)")
            completion()
        }
        
        guard let board = pieceDetector?.getBoard(from: newBoardDetections, pieces: newPieceDetections, player: currentPlayer) else {
            print("Failed to convert detections to board")
            return
        }
        
        let game = Game(for: board, currentPlayer: self.currentPlayer)
        board.debugPrint()
        
        let (score, move) = game.bestMove(depth: 3)
        
        if let bestMove = move {
            print("Best move: \(bestMove.from) → \(bestMove.to), score: \(score)")
        }
        
        if let winner = game.checkWinner() {
            print("Game over. Winner: \(winner)")
        }
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
        print("Updated actualImageFrame: \(actualImageFrame) for containerSize: \(containerSize)")
    }
}
