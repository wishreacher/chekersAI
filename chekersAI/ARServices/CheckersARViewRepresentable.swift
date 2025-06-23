//
//  CheckersARViewRepresentable.swift
//  chekersAI
//
//  Created by Iryna on 23.06.2025.
//

import Foundation
import SwiftUI

struct CheckersARViewRepresentable: UIViewRepresentable{
    func makeUIView(context: Context) -> CheckersARView {
        let view = CheckersARView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func updateUIView(_ uiView: CheckersARView, context: Context) {}
}
