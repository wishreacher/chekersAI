import SwiftUI

struct CameraView: View {
    var body: some View {
        Text("Camera Selection View")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green.opacity(0.1))
    }
}

#Preview {
    CameraView()
}
