import Foundation
import Vision

func convertRect(from normalizedRect: CGRect, in imageFrame: CGRect) -> CGRect {
    let x = imageFrame.origin.x + normalizedRect.origin.x * imageFrame.width
    let y = imageFrame.origin.y + (1.0 - normalizedRect.origin.y - normalizedRect.height) * imageFrame.height
    let width = normalizedRect.width * imageFrame.width
    let height = normalizedRect.height * imageFrame.height

    return CGRect(x: x, y: y, width: width, height: height).standardized
}

func positionToImageOffset(row: Int, col: Int, in frame: CGRect) -> CGPoint {
    let boardSize = 8

    let squareWidth = frame.width / CGFloat(boardSize)
    let squareHeight = frame.height / CGFloat(boardSize)

    let x = frame.origin.x + CGFloat(col) * squareWidth + squareWidth / 2
    let y = frame.origin.y + CGFloat(row) * squareHeight + squareHeight / 2

    return CGPoint(x: x, y: y)
}
