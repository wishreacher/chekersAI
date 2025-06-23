//
//  CheckersARView.swift
//  chekersAI
//
//  Created by Iryna on 23.06.2025.
//

import ARKit
import RealityKit
import SwiftUI

final class CheckersARView: ARView, ARSessionDelegate{
    var isPlaneDetected = false
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        setupSession()
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    private func setupSession() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        session.delegate = self
        session.run(config)
        
    }
    
    func analyzeCurrentFrame(with model: ImageAnalysisViewModel, containerSize: CGSize) {
        self.snapshot(saveToHDR: false) { image in
            guard let image = image else {
                return
            }
            
            model.updateImageFrames(containerSize: containerSize, image: image)
            
            model.analyzeImage(image) { [weak self] in
                guard let self = self else { return }

                if let move = model.bestMove {
                    let (from3DOpt, to3DOpt) = convertMoveTo3DPoints(move, in: model.actualImageFrame, using: self)
                    if let from3D = from3DOpt, let to3D = to3DOpt {
                        self.drawArrow(from: from3D, to: to3D)
                    } else {
                        print("Не вдалося конвертувати координати у 3D")
                    }
                }
            }
        }
    }

    func convertScreenPointToWorld(_ point: CGPoint) -> SIMD3<Float>? {
        guard let query = self.makeRaycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal),
              let result = self.session.raycast(query).first else {
            print("Raycast не знайшов площину для точки \(point)")
            return nil
        }
        
        let position = result.worldTransform.columns.3
        return SIMD3<Float>(position.x, position.y, position.z)
    }

    func drawArrow(from: SIMD3<Float>, to: SIMD3<Float>) {
        let direction = normalize(to - from)
        let length = distance(from, to)

        let shaftLength: Float = length * 0.8
        let shaftMesh = MeshResource.generateBox(size: [0.01, 0.01, shaftLength])
        let shaftMaterial = SimpleMaterial(color: .yellow, isMetallic: false)
        let shaft = ModelEntity(mesh: shaftMesh, materials: [shaftMaterial])
        shaft.position = from + direction * (shaftLength / 2)
        shaft.look(at: to, from: shaft.position, relativeTo: nil)
        

        let headLength: Float = length * 0.2
        let coneMesh = MeshResource.generateCone(height: headLength, radius: 0.02)
        let coneMaterial = SimpleMaterial(color: .yellow, isMetallic: false)
        let head = ModelEntity(mesh: coneMesh, materials: [coneMaterial])
        head.position = from + direction * (shaftLength + headLength / 2)
        
        let up = SIMD3<Float>(0, 1, 0)
        let rotation = simd_quatf(from: up, to: direction)
        head.orientation = rotation
        
        let anchor = AnchorEntity(world: from)
        anchor.addChild(shaft)
        anchor.addChild(head)
        self.scene.anchors.append(anchor)
    }
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                print("✅ Знайдено площину з розміром: \(planeAnchor.extent)")
                NotificationCenter.default.post(name: NSNotification.Name("planeDetected"), object: nil)
            }
        }
    }
}



