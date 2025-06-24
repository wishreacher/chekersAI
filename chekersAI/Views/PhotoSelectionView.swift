import SwiftUI
import _PhotosUI_SwiftUI

struct PhotoSelectionView: View {
    @ObservedObject var viewModel: ImageAnalysisViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Best Move: 🤩")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.vertical, 15)
            
            Text(viewModel.moveToString())
                .monospaced()
                .frame(height: 20)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .overlay {
                        ZStack {
//                            viewModel.drawDetections()
//                            
                            if let bestMove = viewModel.bestMove {
                                ArrowOverlay(move: bestMove, frame: viewModel.actualImageFrame, color: .yellow)
                            }
                        }
                    }
                    .background {
                        viewModel.makeUpdater(image: image)
                    }
            } else {
                Group {
                    Text("")
                } .frame(maxHeight: 400)
            }
            
            Spacer()
        }
        .padding(.horizontal, 25)
    }
}

#Preview {
    let image = UIImage(named: "test")!
    let vm = ImageAnalysisViewModel(image: image)
    PhotoSelectionView(viewModel: vm)
}
