//
//  Miscellaneous.swift
//  chekersAI
//
//  Created by Володимир on 12.06.2025.
//

import Foundation
import Vision

func convertRect(from normalizedRect: CGRect, in imageFrame: CGRect) -> CGRect {
    let x = imageFrame.origin.x + normalizedRect.origin.x * imageFrame.width
    let y = imageFrame.origin.y + (1.0 - normalizedRect.origin.y - normalizedRect.height) * imageFrame.height
    let width = normalizedRect.width * imageFrame.width
    let height = normalizedRect.height * imageFrame.height

    return CGRect(x: x, y: y, width: width, height: height).standardized
}

func convertVisionRectToUIRect(visionRect: CGRect, imageFrame: CGRect) -> CGRect {
    let imageWidth = imageFrame.width
    let imageHeight = imageFrame.height
    
    let x = visionRect.origin.x * imageWidth + imageFrame.origin.x
    let y = (1 - visionRect.origin.y - visionRect.height) * imageHeight + imageFrame.origin.y
    let width = visionRect.size.width * imageWidth
    let height = visionRect.size.height * imageHeight
    
    return CGRect(x: x, y: y, width: width, height: height)
}

func boardBoundingBox(from rectangles: [VNRectangleObservation], in imageFrame: CGRect) -> CGRect? {
    guard !rectangles.isEmpty else { return nil }

    let convertedRects = rectangles.map {
        convertVisionRectToUIRect(visionRect: $0.boundingBox, imageFrame: imageFrame)
    }

    let minX = convertedRects.map { $0.minX }.min() ?? 0
    let minY = convertedRects.map { $0.minY }.min() ?? 0
    let maxX = convertedRects.map { $0.maxX }.max() ?? 0
    let maxY = convertedRects.map { $0.maxY }.max() ?? 0

    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}
