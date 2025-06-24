import SwiftUI
import _PhotosUI_SwiftUI

struct NavigationBarView: View {
    @ObservedObject var viewModel: ContentViewModel
    @ObservedObject var analysisViewModel: ImageAnalysisViewModel
    @ObservedObject var analyzer: ImageAnalysisViewModel
    
    @State var canAnalyze: Bool = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Button(action: {
                        if analysisViewModel.currentPlayer == .black {
                            analysisViewModel.currentPlayer = .white
                            analyzer.arViewRep.view.scene.anchors.removeAll()
                        } else {
                            analysisViewModel.currentPlayer = .black
                            analyzer.arViewRep.view.scene.anchors.removeAll()
                        }
                        
                        
                        if analysisViewModel.selectedImage != nil {
                            analysisViewModel.analyzeImage(analysisViewModel.selectedImage!) {
                                
                            }
                        }
                    }, label: {
                        if analysisViewModel.currentPlayer == .black {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                        } else {
                            Image(systemName: "crown")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                        }
                    })
                    .frame(width: 50, height: 50)
                }
                .background(
                    Capsule()
                        .fill(Material.ultraThin)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                )
                
                if (viewModel.selectedTab == .photo) {
                    PhotosPicker(selection: $analysisViewModel.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        Text("Select Photo")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .onChange(of: analysisViewModel.selectedPhotoItem) { _, newItem in
                        analysisViewModel.handlePhotoUpdate(newItem: newItem)
                    }
                } else {
                    if canAnalyze {
                        Button("Draw Arrow") {
                            analyzer.reset_data()
                            analyzer.arViewRep.analyze(using: analyzer)
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    } else {
                        Button("Searching for plane") {
                            
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .disabled(true)
                    }
                }
            }
            
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: {
                        viewModel.selectedTab = tab
                        analyzer.reset_data()
                        analyzer.arViewRep.view.scene.anchors.removeAll()
                        analysisViewModel.reset_data()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.systemImage)
                                .font(.title2)
                            Text(tab.displayName)
                                .font(.caption)
                        }
                        .foregroundColor(viewModel.selectedTab == tab ? .accentColor : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Material.ultraThin)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            )

            .padding(.bottom, 0)
        }
        .padding(.horizontal, 40)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name(rawValue: "planeDetected"))) { notification in
            canAnalyze = true
        }
        .onDisappear() {
            canAnalyze = false
        }
    }
}

#Preview {
    NavigationBarView(viewModel: ContentViewModel(), analysisViewModel: ImageAnalysisViewModel(), analyzer: ImageAnalysisViewModel())
}
