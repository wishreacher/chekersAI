//
//  CheckersARView.swift
//  chekersAI
//
//  Created by Iryna on 23.06.2025.
//

import ARKit
import RealityKit
import SwiftUI

final class CheckersARView: ARView{
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
//        setupSession()
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
//    private func setupSession() {
//            let config = ARWorldTrackingConfiguration()
//            config.planeDetection = [.horizontal, .vertical]
//            session.run(config)
//        }
}
