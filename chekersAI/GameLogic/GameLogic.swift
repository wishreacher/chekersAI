final class Game{
    var board: Board
    var currentPlayer: Player
    
    init(for board: Board = .emptyBoard(), currentPlayer: Player = .white) {
        self.board = board
        self.currentPlayer = currentPlayer
    }
    
    func updateBoard(from detectedBoard: Board) {
        self.board = detectedBoard
    }
    
    func bestMove(depth: Int = 3) -> (Int, Move?) {
            return minimax(
                board: board,
                depth: depth,
                maximizingPlayer: true,
                player: currentPlayer
            )
        }
    
    func checkWinner() -> Player? {
        if board.allMoves(for: .white).isEmpty{
            return .black
        }else if board.allMoves(for: .black).isEmpty{
            return.white
        }
        
        return nil
    }
}
