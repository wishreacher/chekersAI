//
//  ChekerBoardModel.swift
//  chekersAI
//
//  Created by Володимир on 12.06.2025.
//

import Foundation

struct Board {
    var board: [[Piece]]
    
    func debugPrint() {
        for row in board {
            let rowString = row.map { piece in
                switch piece {
                case .white: return "○"
                case .black: return "●"
                case .empty: return "."
                case .blackKing: return "X"
                case .whiteKing: return "Y"
                }
            }.joined(separator: " ")
            print(rowString)
        }
    }
    
    func evaluate(for player: Player) -> Int {
        let total = board.flatMap { $0 }.reduce(0) { $0 + $1.rawValue }
        return player == .white ? total : -total
    }
    
    
    func apply(_ move: Move) -> Board {
        var newBoard = self.board
        
        let piece = newBoard[move.from.0][move.from.1]
        newBoard[move.from.0][move.from.1] = .empty
        newBoard[move.to.0][move.to.1] = piece
        
        for cap in move.captured {
            newBoard[cap.0][cap.1] = .empty
        }
        
        if piece == .white && move.to.0 == 0 {
            newBoard[move.to.0][move.to.1] = .whiteKing
        } else if piece == .black && move.to.0 == 7 {
            newBoard[move.to.0][move.to.1] = .blackKing
        }
        
        return Board(board: newBoard)
    }
    
    func allMoves(for player: Player) -> [Move] {
        var allMoves: [Move] = []
        var captureMoves: [Move] = []
        
        for row in 0..<8 {
            for col in 0..<8 {
                let piece = board[row][col]
                guard piece != .empty else { continue }
                guard piece.belongs(to: player) else { continue }
                
                let (captures, normals) = getValidMoves(forRow: row, col: col)
                captureMoves.append(contentsOf: captures)
                if captures.isEmpty {
                    allMoves.append(contentsOf: normals)
                }
            }
        }
        
        return captureMoves.isEmpty ? allMoves : captureMoves
    }
    
    
    func getValidMoves(forRow row: Int, col: Int) -> ([Move], [Move]) {
        let piece = board[row][col]
        var captures: [Move] = []
        var normals: [Move] = []
        
        let isKing = piece.isKing
        let isWhite = piece.isWhite
        
        let directions: [(Int, Int)] = isKing
        ? [(-1, -1), (-1, 1), (1, -1), (1, 1)]
        : isWhite ? [(-1, -1), (-1, 1)] : [(1, -1), (1, 1)]
        
        for (dRow, dCol) in directions {
            let newRow = row + dRow
            let newCol = col + dCol
            
            if isInBounds(newRow, newCol), board[newRow][newCol] == .empty {
                normals.append(Move(from: (row, col), to: (newRow, newCol), captured: []))
            }
            
            let jumpRow = row + 2 * dRow
            let jumpCol = col + 2 * dCol
            if isInBounds(jumpRow, jumpCol),
               board[jumpRow][jumpCol] == .empty {
                let midPiece = board[row + dRow][col + dCol]
                if midPiece.isOpponent(of: piece) {
                    captures.append(Move(
                        from: (row, col),
                        to: (jumpRow, jumpCol),
                        captured: [(row + dRow, col + dCol)]
                    ))
                }
            }
        }
        return (captures, normals)
    }
    
    
    private func isInBounds(_ row: Int, _ col: Int) -> Bool {
        return (0..<8).contains(row) && (0..<8).contains(col)
    }
    
    private func isOpponent(of piece: Piece, other: Piece) -> Bool {
        switch (piece, other) {
        case (.white, .black), (.white, .blackKing),
            (.whiteKing, .black), (.whiteKing, .blackKing):
            return true
        case (.black, .white), (.black, .whiteKing),
            (.blackKing, .white), (.blackKing, .whiteKing):
            return true
        default:
            return false
        }
    }
    
    static func emptyBoard() -> Board{
        return Board(board: Array(repeating: Array(repeating: .empty, count: 8), count: 8))
    }
}


