import Foundation
import SwiftUI

struct ArrowOverlay: View {
    let move: Move
    let frame: CGRect
    let color: Color

    var body: some View {
        Canvas { context, size in
            let from = positionToImageOffset(row: move.from.0, col: move.from.1, in: frame)
            let to = positionToImageOffset(row: move.to.0, col: move.to.1, in: frame)

            let path = arrowPath(from: from, to: to)
            context.stroke(path, with: .color(color), lineWidth: 4)
            context.fill(path, with: .color(color))
        }
    }

    func arrowPath(from: CGPoint, to: CGPoint) -> Path {
        var path = Path()
        
        // Shaft
        path.move(to: from)
        path.addLine(to: to)
        
        // Arrowhead
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 12
        let arrowAngle: CGFloat = .pi / 7  // narrower arrow head

        let point1 = CGPoint(
            x: to.x - arrowLength * cos(angle - arrowAngle),
            y: to.y - arrowLength * sin(angle - arrowAngle)
        )

        let point2 = CGPoint(
            x: to.x - arrowLength * cos(angle + arrowAngle),
            y: to.y - arrowLength * sin(angle + arrowAngle)
        )

        // Create triangle for arrowhead
        path.move(to: point1)
        path.addLine(to: to)
        path.addLine(to: point2)
        path.closeSubpath() // closes the triangle

        return path
    }

}
