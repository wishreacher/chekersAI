
enum Player: String{
    case white
    case black
}

func opponent(of player: Player) -> Player {
    return player == .white ? .black : .white
}
