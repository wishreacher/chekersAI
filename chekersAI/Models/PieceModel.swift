
enum Piece: Int {
    case empty = 0
    case white = 1
    case black = -1
    case blackKing = -2
    case whiteKing = 2
}

extension Piece {
    func belongs(to player: Player) -> Bool {
        switch (self, player) {
        case (.white, .white), (.whiteKing, .white),
             (.black, .black), (.blackKing, .black):
            return true
        default:
            return false
        }
    }

    var isWhite: Bool {
        self == .white || self == .whiteKing
    }

    var isKing: Bool {
        self == .whiteKing || self == .blackKing
    }

    func isOpponent(of piece: Piece) -> Bool {
        switch (self, piece) {
        case (.white, .black), (.white, .blackKing),
             (.whiteKing, .black), (.whiteKing, .blackKing),
             (.black, .white), (.black, .whiteKing),
             (.blackKing, .white), (.blackKing, .whiteKing):
            return true
        default:
            return false
        }
    }
}
