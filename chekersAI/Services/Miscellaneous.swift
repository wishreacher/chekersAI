//
//  Miscellaneous.swift
//  chekersAI
//
//  Created by Володимир on 12.06.2025.
//

import Foundation

func convertRect(from normalizedRect: CGRect, in imageFrame: CGRect) -> CGRect {
    let x = imageFrame.origin.x + normalizedRect.origin.x * imageFrame.width
    let y = imageFrame.origin.y + (1.0 - normalizedRect.origin.y - normalizedRect.height) * imageFrame.height
    let width = normalizedRect.width * imageFrame.width
    let height = normalizedRect.height * imageFrame.height

    return CGRect(x: x, y: y, width: width, height: height).standardized
}
