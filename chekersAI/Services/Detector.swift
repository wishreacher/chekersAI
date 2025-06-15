//
//  Detector.swift
//  chekersAI
//
//  Created by Володимир on 14.06.2025.
//

import Foundation
import SwiftUI
import Vision

class Detector {
    var analysisResult: String?
    var detections: [Detection] = []
    var containerFrame: CGRect = .zero
    var actualImageFrame: CGRect = .zero
    var boundingBoxes: [CGRect] = []
    
    let image: UIImage
    
    
    init(image: UIImage) {
        self.image = image
    }
    
    func reset() {
        detections = []
        containerFrame = .zero
        actualImageFrame = .zero
        boundingBoxes = []
    }
}

protocol DetectionProtocol {
    func detect() -> [Detection]
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
