import Foundation
import SwiftUI
import PhotosUI
import CoreML
import Vision

class ImageAnalysisViewModel: NSObject, ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var actualImageFrame: CGRect
    @Published var containerFrame: CGRect
    @Published var currentPlayer: Player = .black
    @Published var boardDetections: [Detection] = []
    @Published var pieceDetections: [Detection] = []
    @Published var analysisCompleted = false
    @Published var bestMove: Move?
    
    private var boardDetector: BoardDetector?
    private var pieceDetector: PieceDetector?
    
    init(actualImageFrame: CGRect = .zero, containerFrame: CGRect = .zero) {
        self.actualImageFrame = actualImageFrame
        self.containerFrame = containerFrame
        super.init()
    }
    
    func analyzeImage(_ image: UIImage, completion: @escaping () -> Void) {
        print("Starting analysis for image with size: \(image.size), actualImageFrame: \(actualImageFrame)")
        
        DispatchQueue.main.async { [weak self] in
            self?.boardDetections = []
            self?.pieceDetections = []
            self?.boardDetector = nil
            self?.pieceDetector = nil
        }
        
        boardDetector = BoardDetector(image: image)
        pieceDetector = PieceDetector(image: image)
        
        boardDetector?.reset()
        pieceDetector?.reset()
        
        let newBoardDetections = boardDetector?.detect() ?? []
        let newPieceDetections = pieceDetector?.detect() ?? []
        
        DispatchQueue.main.async { [weak self] in
            self?.boardDetections = newBoardDetections
            self?.pieceDetections = newPieceDetections
            print("Updated detections: Board: \(newBoardDetections.count), Pieces: \(newPieceDetections.count)")
            completion()
        }
        
        guard let board = pieceDetector?.getBoard(from: newBoardDetections, pieces: newPieceDetections, player: currentPlayer) else {
            print("Failed to convert detections to board")
            return
        }
        
        let game = Game(for: board, currentPlayer: self.currentPlayer)
        board.debugPrint()
        
        let (score, move) = game.bestMove(depth: 3)
        
        if move != nil {
            bestMove = move
            print("Best move: \(move!.from) → \(move!.to), score: \(score)")
        }
        
        if let winner = game.checkWinner() {
            print("Game over. Winner: \(winner)")
        }
    }
    
    func updateImageFrames(containerSize: CGSize, image: UIImage) {
        containerFrame = CGRect(origin: .zero, size: containerSize)
        
        let imageSize = image.size
        let containerAspectRatio = containerSize.width / containerSize.height
        let imageAspectRatio = imageSize.width / imageSize.height
        
        var actualImageSize: CGSize
        var imageOffset: CGPoint
        
        if imageAspectRatio > containerAspectRatio {
            actualImageSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspectRatio
            )
            imageOffset = CGPoint(
                x: 0,
                y: (containerSize.height - actualImageSize.height) / 2
            )
        } else {
            actualImageSize = CGSize(
                width: containerSize.height * imageAspectRatio,
                height: containerSize.height
            )
            imageOffset = CGPoint(
                x: (containerSize.width - actualImageSize.width) / 2,
                y: 0
            )
        }
        
        actualImageFrame = CGRect(origin: imageOffset, size: actualImageSize)
        print("Updated actualImageFrame: \(actualImageFrame) for containerSize: \(containerSize)")
    }
    
    func handlePhotoUpdate(newItem: PhotosPickerItem?) {
        DispatchQueue.main.async { [unowned self] in
            selectedImage = nil
            boardDetections = []
            pieceDetections = []
            actualImageFrame = .zero
            self.analysisCompleted = false
            print("Photo selection cleared or new selection started")
        }
        
        guard let newItem = newItem else { return }
        
        Task {
            do {
                if let data = try await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        print("Loaded new photo with size: \(uiImage.size)")
                        self.selectedImage = uiImage
                    }
                }
            } catch {
                print("Failed to load photo: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - Views
    @ViewBuilder
    func drawDetections(detections: [Detection], imageFrame: CGRect, color: Color = .blue) -> some View {
        ForEach(detections) { detection in
            let rect = convertRect(from: detection.boundingBox, in: imageFrame)
            
            Rectangle()
                .stroke(color, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
            
            Text("\(detection.label) (\(Int(detection.confidence * 100))%)")
                .font(.caption)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.7))
                .position(x: rect.midX, y: rect.minY - 10)
        }
    }
    
    @ViewBuilder
    func drawDetections() -> some View {
        if analysisCompleted {
            drawDetections(detections: boardDetections, imageFrame: actualImageFrame, color: .blue)
            drawDetections(detections: pieceDetections, imageFrame: actualImageFrame, color: .red)
        }
    }
    
    @ViewBuilder
    func makeUpdater(image: UIImage) -> some View {
        GeometryReader { geo in
            Color.clear
                .onAppear {
                    print("Photo view appeared with container size: \(geo.size)")
                    self.updateImageFrames(containerSize: geo.size, image: image)
                    DispatchQueue.main.async {
                        print("Triggering analysis from onAppear for image: \(image.size)")
                        self.analyzeImage(image) {
                            self.analysisCompleted = true
                        }
                    }
                }
                .onChange(of: geo.size) { _, newSize in
                    print("Container size changed to: \(newSize)")
                    self.updateImageFrames(containerSize: newSize, image: image)
                    DispatchQueue.main.async {
                        print("Triggering analysis from container size change")
                        self.analyzeImage(image) {
                            self.analysisCompleted = true
                        }
                    }
                }
        }
    }
}
