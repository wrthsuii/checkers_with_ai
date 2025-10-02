//  Move.swift
//  checkers-with-ai

import Foundation

struct Move: Equatable {
    let from: (row: Int, col: Int)
    let to: (row: Int, col: Int)
    let capturedPieces: [(row: Int, col: Int)]
    var isCapture: Bool {return !capturedPieces.isEmpty}
    
    var capturedPiece: (row: Int, col: Int)? {
        return capturedPieces.first
    }
    
    init(from: (Int, Int), to: (Int, Int), capturedPieces: [(Int, Int)] = []) {
        self.from = from
        self.to = to
        self.capturedPieces = capturedPieces
    }
    
    init(from: (Int, Int), to: (Int, Int), capturedPiece: (Int, Int)?) {
        self.from = from
        self.to = to
        self.capturedPieces = capturedPiece.map { [$0] } ?? []
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
}
