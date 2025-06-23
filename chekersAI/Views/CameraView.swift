import SwiftUI

struct CameraView: View {
    @ObservedObject var analyzer: ImageAnalysisViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Best Move: 🤩")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.vertical, 15)
            
            Text(analyzer.moveToString())
                .monospaced()
                .frame(height: 20)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Spacer()
            
            Text("Наведіть камеру на дошку")
                .font(.headline)
            Spacer()
            
            analyzer.arViewRep
                .frame(width: 300, height: 300)
                .padding(.bottom, 150)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//#Preview {
//    CameraView(analyzer: ImageAnalysisViewModel())
//}
