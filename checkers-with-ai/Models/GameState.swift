//  GameState.swift
//  checkers-with-ai

import Foundation

class GameState: ObservableObject {
    @Published var currentPlayer: Player = .human
    @Published var selectedPiece: Piece?
    @Published var possibleMoves: [Move] = []
    @Published var gameOver = false
    @Published var winner: Player?
    
    func switchPlayer() {
        currentPlayer = currentPlayer.opposite
        selectedPiece = nil
        possibleMoves = []
    }
    
    func checkGameOver(board: Board) {
        let humanMoves = board.getAllPossibleMoves(for: .human)
        let aiMoves = board.getAllPossibleMoves(for: .ai)
        
        if humanMoves.isEmpty {
            gameOver = true
            winner = .ai
        } else if aiMoves.isEmpty {
            gameOver = true
            winner = .human
        }
    }
}
