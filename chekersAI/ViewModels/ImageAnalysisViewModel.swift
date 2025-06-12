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
    @Published var analysisResult: String?
    @Published var detections: [Detection] = []
    @Published var containerFrame: CGRect = .zero
    @Published var actualImageFrame: CGRect = .zero
    @Published var boundingBoxes: [CGRect] = []
    
    // Temporary storage for detections from each model
    private var objectDetections: [Detection] = []
    private var boardDetections: [Detection] = []
    
    @ViewBuilder
    func drawDetections(detections: [Detection], imageFrame: CGRect) -> some View {
        ForEach(detections) { detection in
            let rect = convertRect(from: detection.boundingBox, in: imageFrame)
            
            // Use different colors for board vs. other objects (optional)
            let color = detection.label == "board" ? Color.green : Color.red
            
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
        guard let cgImage = image.cgImage else { return }
        
        let mlConfig = MLModelConfiguration()
        #if targetEnvironment(simulator)
            mlConfig.computeUnits = .cpuOnly
        #endif
        
        // Clear previous detections
        detections = []
        objectDetections = []
        boardDetections = []
        
        do {
            // Load both models
            let objectModel = try VNCoreMLModel(for: checkersAI_1(configuration: mlConfig).model)
            let boardModel = try VNCoreMLModel(for: BoardDetector_2_Iteration_530(configuration: mlConfig).model)
            
            // Create Vision requests for both models
            let objectRequest = VNCoreMLRequest(model: objectModel) { request, error in
                self.processDetections(from: request, error: error, type: "object")
            }
            
            let boardRequest = VNCoreMLRequest(model: boardModel) { request, error in
                self.processDetections(from: request, error: error, type: "board")
            }
            
            // Perform both requests on the same image
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([objectRequest, boardRequest])
        } catch {
            DispatchQueue.main.async {
                self.analysisResult = "Failed to analyze: \(error.localizedDescription)"
            }
            print("Error: \(error)")
        }
    }
    
    private func processDetections(from request: VNRequest, error: Error?, type: String) {
        guard let results = request.results as? [VNRecognizedObjectObservation] else {
            DispatchQueue.main.async {
                self.analysisResult = "No valid detection results for \(type)."
            }
            print("No valid results for \(type).")
            return
        }
        
        let newDetections: [Detection] = results.compactMap { result in
            guard let topLabel = result.labels.first else { return nil }
            return Detection(
                label: topLabel.identifier,
                confidence: topLabel.confidence,
                boundingBox: result.boundingBox
            )
        }
        
        DispatchQueue.main.async {
            if type == "object" {
                self.objectDetections = newDetections
            } else if type == "board" {
                self.boardDetections = newDetections
            }
            self.updateDetections()
        }
    }
    
    private func updateDetections() {
        detections = objectDetections + boardDetections
        analysisResult = "\(detections.count) detected"
    }
}
