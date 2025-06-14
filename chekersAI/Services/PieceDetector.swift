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
}
