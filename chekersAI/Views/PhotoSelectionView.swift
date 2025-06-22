import SwiftUI
import _PhotosUI_SwiftUI

struct PhotoSelectionView: View {
    @ObservedObject var viewModel: ImageAnalysisViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
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
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }
            
            PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                Text("Select Photo")
                    .foregroundColor(.blue)
                    .padding()
            }
            .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
                viewModel.handlePhotoUpdate(newItem: newItem)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PhotoSelectionView(viewModel: ImageAnalysisViewModel())
}
