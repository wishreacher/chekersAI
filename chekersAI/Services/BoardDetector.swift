//
//  BoardDetector.swift
//  chekersAI
//
//  Created by Володимир on 14.06.2025.
//

import Foundation
import Vision
import UIKit
import CoreGraphics

final class BoardDetector: Detector, DetectionProtocol {
    // MARK: - Constants
    private let maximumObservations = 100
    private let minimumConfidence: VNConfidence = 0.5
    private let minimumSize: Float = 0.05
    
    // MARK: - Properties for Rotation
    private(set) var averageAngle: Double?
    private(set) var boardCenter: CGPoint?
    private(set) var minTransformedX: CGFloat?
    private(set) var maxTransformedX: CGFloat?
    private(set) var minTransformedY: CGFloat?
    private(set) var maxTransformedY: CGFloat?
    
    var isDetecting: Bool = false
    
    func processDetections(from request: VNRequest, error: Error?) -> [Detection] {
        guard let results = request.results as? [VNRectangleObservation] else {
            print("No valid results for board detection.")
            return []
        }

        // Filter: confident squares
        let squares = results.filter {
            $0.confidence >= minimumConfidence &&
            abs($0.boundingBox.width - $0.boundingBox.height) <= 0.1 &&
            $0.boundingBox.width >= CGFloat(minimumSize) &&
            $0.boundingBox.height >= CGFloat(minimumSize)
        }

        guard squares.count >= 20 else {
            print("Not enough squares to identify board.")
            return []
        }

        // Compute average angle
        var sumSin: Double = 0
        var sumCos: Double = 0
        for square in squares {
            let vec = CGVector(dx: square.bottomRight.x - square.bottomLeft.x,
                             dy: square.bottomRight.y - square.bottomLeft.y)
            let angle = atan2(vec.dy, vec.dx)
            sumSin += CoreGraphics.sin(angle)
            sumCos += CoreGraphics.cos(angle)
        }
        let averageAngle = atan2(sumSin / Double(squares.count), sumCos / Double(squares.count))
        self.averageAngle = averageAngle

        // Get the union bounding box of all squares
        let boardRect = squares.reduce(into: squares[0].boundingBox) { partialResult, observation in
            partialResult = partialResult.union(observation.boundingBox)
        }
        
        // Compute board center
        let boardCenter = CGPoint(x: boardRect.midX, y: boardRect.midY)
        self.boardCenter = boardCenter
        
        // Compute transformed centers for grid extents
        let centers = squares.map { observation in
            let x = (observation.topLeft.x + observation.topRight.x +
                    observation.bottomLeft.x + observation.bottomRight.x) / 4
            let y = (observation.topLeft.y + observation.topRight.y +
                    observation.bottomLeft.y + observation.bottomRight.y) / 4
            return CGPoint(x: x, y: y)
        }
        
        let transformedCenters = centers.map { point in
            let translated = CGPoint(x: point.x - boardCenter.x, y: point.y - boardCenter.y)
            let rotated = CGPoint(
                x: translated.x * cos(-averageAngle) - translated.y * sin(-averageAngle),
                y: translated.x * sin(-averageAngle) + translated.y * cos(-averageAngle)
            )
            return CGPoint(x: rotated.x + boardCenter.x, y: rotated.y + boardCenter.y)
        }
        
        // Store grid extents
        self.minTransformedX = transformedCenters.map { $0.x }.min()
        self.maxTransformedX = transformedCenters.map { $0.x }.max()
        self.minTransformedY = transformedCenters.map { $0.y }.min()
        self.maxTransformedY = transformedCenters.map { $0.y }.max()

        return [Detection(label: "Board", confidence: 1.0, boundingBox: boardRect)]
    }
    
    func detect() -> [Detection] {
        guard let cgImage = image.cgImage else { return [] }
        
        reset()
        
        isDetecting = true
        
        let rectangleRequest = VNDetectRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            
            self.isDetecting = false
            self.detections = self.processDetections(from: request, error: error)
            print("Board detection process complete")
        }
    
        rectangleRequest.minimumSize = minimumSize
        rectangleRequest.maximumObservations = maximumObservations
        rectangleRequest.minimumConfidence = minimumConfidence
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        let imageRequestHandler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: orientation,
            options: [:]
        )
    
        do {
            try imageRequestHandler.perform([rectangleRequest])
        } catch {
            DispatchQueue.main.async {
                self.isDetecting = false
                print("Rectangle detection failed: \(error.localizedDescription)")
            }
        }
        
        return self.detections
    }
    
    /// Maps a point to an 8x8 grid, accounting for board rotation
    func mapToGrid(point: CGPoint) -> (Int, Int)? {
        guard let angle = averageAngle,
              let center = boardCenter,
              let minX = minTransformedX,
              let maxX = maxTransformedX,
              let minY = minTransformedY,
              let maxY = maxTransformedY,
              maxX > minX, maxY > minY else { return nil }
              
        // Transform the point by rotating it back
        let translated = CGPoint(x: point.x - center.x, y: point.y - center.y)
        let rotated = CGPoint(
            x: translated.x * cos(-angle) - translated.y * sin(-angle),
            y: translated.x * sin(-angle) + translated.y * cos(-angle)
        )
        let transformed = CGPoint(x: rotated.x + center.x, y: rotated.y + center.y)
        
        // Check if the point is within the board's transformed bounds
        guard transformed.x >= minX && transformed.x <= maxX &&
              transformed.y >= minY && transformed.y <= maxY else { return nil }
              
        // Map to 8x8 grid
        let gridX = Int(8 * (transformed.x - minX) / (maxX - minX))
        let gridY = Int(8 * (transformed.y - minY) / (maxY - minY))
        
        // Ensure indices are within 0-7
        return (min(max(gridX, 0), 7), min(max(gridY, 0), 7))
    }
}
