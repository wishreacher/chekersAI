//
//  ImageAnalysisViewModel.swift
//  chekersAI
//
//  Created by Володимир on 12.06.2025.
//

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
    @Published var cameraPermissionGranted = false
    
    @Published var frame: CGImage?
    
    private let captureSession = AVCaptureSession()
    private let captureQueue = DispatchQueue(label: "camera")
    private let context = CIContext()
    
    private var boardDetector: BoardDetector?
    private var pieceDetector: PieceDetector?
    
    var pieceDetections: [Detection] = []
    var boardDetections: [Detection] = []
    
    init (actualImageFrame: CGRect = .zero, containerFrame: CGRect = .zero) {
        self.actualImageFrame = actualImageFrame
        self.containerFrame = containerFrame
        
        super.init()
        
        checkPermission()
        captureQueue.async { [unowned self] in
            self.setupCameraSession()
            self.captureSession.startRunning()
            
        }
    }
    
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
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
            cameraPermissionGranted = true
        case .denied, .restricted:
            cameraPermissionGranted = false
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.cameraPermissionGranted = granted
                }
            }
        }
    }
    
    func analyzeImage(_ image: UIImage) {
        boardDetector = BoardDetector(image: image)
        pieceDetector = PieceDetector(image: image)
        
        boardDetections = boardDetector?.detect() ?? []
        pieceDetections = pieceDetector?.detect() ?? []
        
        guard let board = pieceDetector?.convertDetections(from: boardDetections, pieces: pieceDetections, player: currentPlayer) else{return}
        
        let game = Game(for: board, currentPlayer: self.currentPlayer)
        board.debugPrint()
        

        let (score, move) = game.bestMove(depth: 3)
        
        if let bestMove = move {
            print("Найкращий хід: \(bestMove.from) → \(bestMove.to), score: \(score)")
        }
        
        if let winner = game.checkWinner() {
            print("Гра завершена. Переможець: \(winner)")
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
    }
    
    private func setupCameraSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        
        guard cameraPermissionGranted else { return }
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferDelegateQueue"))
        captureSession.addOutput(videoOutput)
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
    }
}

extension ImageAnalysisViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return cgImage
    }
}
