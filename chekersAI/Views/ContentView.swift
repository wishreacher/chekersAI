import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = ContentViewModel()
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if viewModel.selectedTab == .photo {
                    PhotoSelectionView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.all, edges: .bottom)
                } else {
                    CameraView()
                }
            }
            NavigationBarView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
