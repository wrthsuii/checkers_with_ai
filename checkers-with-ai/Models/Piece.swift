//  Piece.swift
//  checkers-with-ai

import Foundation

enum PieceType {
    case man
    case king
}

enum Player {
    case human
    case ai
    
    var opposite: Player {
        return self == .human ? .ai : .human
    }
}

struct Piece: Identifiable {
    let id = UUID() // ідентифікатор для кожної шашки, корисно в мінімаксі при копіюванні дошки
    var type: PieceType
    var player: Player
    var position: (row: Int, col: Int)
    
    var isKing: Bool {
        return type == .king
    }
}

