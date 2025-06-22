import SwiftUI
import _PhotosUI_SwiftUI

struct PhotoSelectionView: View {
    @ObservedObject var viewModel: ImageAnalysisViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            if let image = viewModel.selectedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            viewModel.drawDetections()
                        }
                        .background {
                            viewModel.makeUpdater(image: image)
                        }
                }
                .padding(.horizontal)
            }
            
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
        .padding()
    }
}

#Preview {
    PhotoSelectionView(viewModel: ImageAnalysisViewModel())
}
