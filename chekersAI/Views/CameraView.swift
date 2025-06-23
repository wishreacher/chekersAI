import SwiftUI

struct CameraView: View {
    @ObservedObject var analyzer: ImageAnalysisViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Наведіть камеру на дошку")
                .font(.headline)
            
            Spacer()
            analyzer.arViewRep
                .frame(width: 300, height: 300)
                .padding(.bottom, 70)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CameraView(analyzer: ImageAnalysisViewModel())
}
