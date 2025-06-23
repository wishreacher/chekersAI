//
//  CheckersARViewRepresentable.swift
//  chekersAI
//
//  Created by Iryna on 23.06.2025.
//

import Foundation
import SwiftUI

struct CheckersARViewRepresentable: UIViewRepresentable{
    let view = CheckersARView(frame: .zero)
    func makeUIView(context: Context) -> CheckersARView {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func updateUIView(_ uiView: CheckersARView, context: Context) {}
    
//    func sendMove(from: SIMD3<Float>, to: SIMD3<Float>) {
//        view.drawArrow(from: from, to: to)
//    }
    
    func analyze(using model: ImageAnalysisViewModel) {
        let containerSize = view.bounds.size
        view.analyzeCurrentFrame(with: model, containerSize: containerSize)
    }
}
