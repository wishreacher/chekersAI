//
//  BoardDetector.swift
//  chekersAI
//
//  Created by Володимир on 14.06.2025.
//

import Foundation
import Vision
import UIKit

final class BoardDetector: Detector, DetectionProtocol {
    //MARK: - Constants
    private let maximumObservations = 100
    private let minimumCofidence: VNConfidence = 0.5
    private let minimumAspectRatio: VNAspectRatio = 0.8
    private let maximumAspectRatio: VNAspectRatio = 1.2
    private let minimumSize: Float = 0.05

    var isDetecting: Bool = false
    
    func processDetections(from request: VNRequest, error: Error?) -> [Detection] {
        guard let results = request.results as? [VNRectangleObservation] else {
            print("No valid results for board detection.")
            return []
        }
        
        let detections: [Detection] = results.map { result in
            return Detection(
                label: "square",
                confidence: result.confidence,
                boundingBox: result.boundingBox
            )
        }
        
        let minX = detections.map { $0.boundingBox.minX }.min() ?? 0
        let minY = detections.map { $0.boundingBox.minY }.min() ?? 0
        let maxX = detections.map { $0.boundingBox.maxX }.max() ?? 0
        let maxY = detections.map { $0.boundingBox.maxY }.max() ?? 0
        
        return [Detection(label: "Board", confidence: 1, boundingBox: CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY))]
    }
    
    func detect() -> [Detection] {
        guard let cgImage = image.cgImage else { return [] }
        
        isDetecting = true
        
        let rectangleRequest = VNDetectRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            
            self.isDetecting = false
            self.detections = self.processDetections(from: request, error: error)
            print("Board detection process complete")
        }
    
        rectangleRequest.minimumSize = minimumSize
        rectangleRequest.maximumObservations = maximumObservations
        rectangleRequest.minimumConfidence = minimumCofidence
        rectangleRequest.minimumAspectRatio = minimumAspectRatio
        rectangleRequest.maximumAspectRatio = maximumAspectRatio
        
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
}
