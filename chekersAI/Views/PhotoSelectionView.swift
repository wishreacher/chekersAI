import SwiftUI
import _PhotosUI_SwiftUI

struct PhotoSelectionView: View {
    @ObservedObject var viewModel: ImageAnalysisViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .overlay {
                        ZStack {
                            viewModel.drawDetections()
                            
                            if let bestMove = viewModel.bestMove {
                                ArrowOverlay(move: bestMove, frame: viewModel.actualImageFrame, color: .yellow)
                            }
                        }
                    }
                    .background {
                        viewModel.makeUpdater(image: image)
                    }
                .padding(.horizontal)
            }
            
            ZStack {
                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                    Text("Select Photo")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200, height: 40)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
                    viewModel.handlePhotoUpdate(newItem: newItem)
                }
            }
        }
        .padding()
    }
}

#Preview {
    PhotoSelectionView(viewModel: ImageAnalysisViewModel())
}
