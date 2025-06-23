import SwiftUI

struct ContentView: View {
    @ObservedObject private var contentViewModel = ContentViewModel()
    @StateObject private var imageViewModel = ImageAnalysisViewModel()
    @ObservedObject var analyzer = ImageAnalysisViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if contentViewModel.selectedTab == .photo {
                    PhotoSelectionView(viewModel: imageViewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.all, edges: .bottom)
                } else {
                    CameraView(analyzer: analyzer)
                }
            }
            NavigationBarView(viewModel: contentViewModel, analysisViewModel: imageViewModel, analyzer: analyzer)
        }
        .background(Color(CGColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)))
    }
}

#Preview {
    ContentView()
}
