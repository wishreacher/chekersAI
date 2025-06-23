import SwiftUI

struct CameraView: View {
    @State private var arViewRep = CheckersARViewRepresentable()
    @ObservedObject var analyzer = ImageAnalysisViewModel()
    var body: some View {
        VStack(spacing: 0) {
            Text("Наведіть камеру на дошку")
                .font(.headline)
            
            Spacer()
            arViewRep
                .frame(width: 300, height: 300)
            Spacer()
            
            Button("Намалювати стрілку") {
//                let from = SIMD3<Float>(0, 0.05, -0.2)
//                let to = SIMD3<Float>(0.1, 0.05, -0.4)
//                arViewRep.sendMove(from: from, to: to)
                arViewRep.analyze(using: analyzer)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CameraView()
}
