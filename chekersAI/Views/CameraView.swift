import SwiftUI

struct CameraView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Наведіть камеру на дошку")
                .font(.headline)
            
            Spacer()
            CheckersARViewRepresentable()
                .frame(width: 350, height: 350)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CameraView()
}
