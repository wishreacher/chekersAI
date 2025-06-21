//
//  PieceDetector.swift
//  chekersAI
//
//  Created by Володимир on 14.06.2025.
//

import Foundation
import Vision

class PieceDetector: Detector, DetectionProtocol {
    func detect() -> [Detection] {
        do {
            guard let cgImage = image.cgImage else { return [] }
            let objectModel = try VNCoreMLModel(for: checkersAI_1().model)
            
            let objectRequest = VNCoreMLRequest(model: objectModel) { request, error in
                self.detections = self.processDetections(from: request, error: error)
            }
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([objectRequest])
        } catch {
            DispatchQueue.main.async {
                self.analysisResult = "Failed to analyze: \(error.localizedDescription)"
            }
            print("Error: \(error)")
        }
        return detections
    }
    
    func processDetections(from request: VNRequest, error: Error?) -> [Detection]{
        guard let results = request.results as? [VNRecognizedObjectObservation] else {
            print("No pieces found")
            return []
        }
        
        let detections: [Detection] = results.compactMap { result in
            guard let topLabel = result.labels.first else { return nil }
            return Detection(
                label: topLabel.identifier,
                confidence: topLabel.confidence,
                boundingBox: result.boundingBox
            )
        }
        
        return detections
    }
    
    func convertDetections(from boardDet: [Detection], pieces: [Detection], player: Player) -> Board{
        var board = Board.emptyBoard()
        
        guard let boardBox = boardDet.first?.boundingBox else {
            print("Board not detected!")
            return board
        }

        for piece in pieces {
            let box = piece.boundingBox
            
            let centerX = box.origin.x + box.width / 2
            let centerY = box.origin.y + box.height / 2
            
            let relativeX = (centerX - boardBox.origin.x) / boardBox.width
            let relativeY = (centerY - boardBox.origin.y) / boardBox.height
            
            let col = Int(relativeX * 8)
            let row = 7 - Int(relativeY * 8)
            
            guard (row + col) % 2 == 1 else {
                print("Skipping invalid square (light tile) at row: \(row), col: \(col)")
                continue
            }
            
            let pieceType = pieceType(for: piece.label, at: row, player: player)
            board.board[row][col] = pieceType
        }
        
        return board
    }
    
    private func pieceType(for label: String, at row: Int, player: Player) -> Piece {
        switch label {
        case "white":
            if player == .white && row == 0 {
                return .whiteKing
            } else if player == .black && row == 7 {
                return .whiteKing
            } else {
                return .white
            }
            
        case "black":
            if player == .black && row == 0 {
                return .blackKing
            } else if player == .white && row == 7 {
                return .blackKing
            } else {
                return .black
            }
            
        default:
            return .empty
        }
    }
}
