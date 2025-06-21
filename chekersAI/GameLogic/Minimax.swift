
func minimax(board: Board, depth: Int, maximizingPlayer: Bool, player: Player) -> (Int, Move?) {
    if depth == 0 {
        return (board.evaluate(for: player), nil)
    }

    let current = maximizingPlayer ? player : opponent(of: player)
    let allMoves = board.allMoves(for: current)

    if allMoves.isEmpty {
        return (board.evaluate(for: player), nil)
    }

    var bestMove: Move? = nil

    if maximizingPlayer {
        var maxEval = Int.min
        for move in allMoves {
            let newBoard = board.apply(move)
            let (eval, _) = minimax(board: newBoard, depth: depth - 1, maximizingPlayer: false, player: player)
            if eval > maxEval {
                maxEval = eval
                bestMove = move
            }
        }
        return (maxEval, bestMove)
    } else {
        var minEval = Int.max
        for move in allMoves {
            let newBoard = board.apply(move)
            let (eval, _) = minimax(board: newBoard, depth: depth - 1, maximizingPlayer: true, player: player)
            if eval < minEval {
                minEval = eval
                bestMove = move
            }
        }
        return (minEval, bestMove)
    }
}

