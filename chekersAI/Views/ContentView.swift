import SwiftUI

struct ContentView: View {
    @ObservedObject private var contentViewModel = ContentViewModel()
    @StateObject private var imageViewModel = ImageAnalysisViewModel()
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if contentViewModel.selectedTab == .photo {
                    PhotoSelectionView(viewModel: imageViewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.all, edges: .bottom)
                } else {
                    CameraView()
                }
            }
            NavigationBarView(viewModel: contentViewModel, analysisViewModel: imageViewModel)
        }
    }
}

#Preview {
    ContentView()
}
