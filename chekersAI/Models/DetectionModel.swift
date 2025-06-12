//
//  DetectionModel.swift
//  chekersAI
//
//  Created by Володимир on 12.06.2025.
//

import Foundation

struct Detection: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    let boundingBox: CGRect
}
