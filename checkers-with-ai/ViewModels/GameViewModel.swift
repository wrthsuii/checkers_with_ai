//  GameViewModel.swift
//  checkers-with-ai

import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var board: Board
    @Published var gameState: GameState
    @Published var humanPiecesCount: Int = 12
    @Published var aiPiecesCount: Int = 12
    private let ai = MinimaxAI()
    
    private var cancellables = Set<AnyCancellable>()
    private var aiMoveWorkItem: DispatchWorkItem?
    
    @Published var highlightedPieces: [(row: Int, col: Int)] = []
    
    init() {
        self.board = Board()
        self.gameState = GameState()
        
        board.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        updateHighlightedPieces()
    }
    
    deinit {
        aiMoveWorkItem?.cancel()
    }
    
    private func updateHighlightedPieces() {
        guard gameState.currentPlayer == .human else {
            highlightedPieces = []
            return
        }
        
        let playerPieces = board.pieces.filter { $0.player == .human }
        var highlighted: [(row: Int, col: Int)] = []
        
        for piece in playerPieces {
            let moves = board.getAllPossibleMoves(for: .human)
            let pieceMoves = moves.filter { $0.from.row == piece.position.row && $0.from.col == piece.position.col }
            
            if !pieceMoves.isEmpty {
                highlighted.append((piece.position.row, piece.position.col))
            }
        }
        
        highlightedPieces = highlighted
    }
    
    func selectPiece(at row: Int, col: Int) {
        guard gameState.currentPlayer == .human,
              !gameState.gameOver else { return }
        
        if let selected = gameState.selectedPiece,
           selected.position.row == row && selected.position.col == col {
            gameState.selectedPiece = nil
            gameState.possibleMoves = []
            updateHighlightedPieces()
            return
        }
        
        if let selectedPiece = gameState.selectedPiece,
           gameState.possibleMoves.contains(where: { $0.to.row == row && $0.to.col == col }) {
            makeMove(to: row, col: col)
            return
        }
        
        if let piece = board.pieceAt(row: row, col: col),
           piece.player == .human {
            
            gameState.selectedPiece = piece
            let allMoves = board.getAllPossibleMoves(for: .human)
            gameState.possibleMoves = allMoves.filter {
                $0.from.row == row && $0.from.col == col
            }
            
            highlightedPieces = [(row, col)]
            
            print("Selected piece at (\(row), \(col)), possible moves: \(gameState.possibleMoves.count)")
        } else {
            gameState.selectedPiece = nil
            gameState.possibleMoves = []
            updateHighlightedPieces()
        }
    }
    
    private func makeMove(to row: Int, col: Int) {
        guard let selectedPiece = gameState.selectedPiece,
              let move = gameState.possibleMoves.first(where: {
                  $0.to.row == row && $0.to.col == col
              }) else {
            print("Invalid move to (\(row), \(col))")
            return
        }
        
        let success = board.movePiece(move)
        
        if success {
            gameState.selectedPiece = nil
            gameState.possibleMoves = []
            updatePiecesCount()
            gameState.checkGameOver(board: board)
            
            if !gameState.gameOver {
                gameState.switchPlayer()
                updateHighlightedPieces()
                scheduleAIMove()
            } else {
                highlightedPieces = []
            }
        }
    }
    
    private func scheduleAIMove() {
        guard gameState.currentPlayer == .ai && !gameState.gameOver else { return }
        
        aiMoveWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.makeAIMove()
        }
        
        aiMoveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    private func makeAIMove() {
        guard gameState.currentPlayer == .ai && !gameState.gameOver else { return }
        
        print("AI is thinking...")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let possibleMoves = self.board.getAllPossibleMoves(for: .ai)
            print("AI has \(possibleMoves.count) possible moves")
            
            if let bestMove = self.ai.findBestMove(for: self.board) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    guard self.gameState.currentPlayer == .ai && !self.gameState.gameOver else { return }
                    
                    let success = self.board.movePiece(bestMove)
                    if success {
                        self.gameState.checkGameOver(board: self.board)
                        updatePiecesCount()
                        if !self.gameState.gameOver {
                            self.gameState.switchPlayer()
                            self.updateHighlightedPieces()
                        } else {
                            self.highlightedPieces = []
                        }
                    }
                }
            } else {
                print("AI found no valid moves")
                DispatchQueue.main.async { [weak self] in
                    self?.gameState.checkGameOver(board: self?.board ?? Board())
                    self?.highlightedPieces = []
                }
            }
        }
    }
    
    func resetGame() {
        aiMoveWorkItem?.cancel()
        aiMoveWorkItem = nil
        
        board = Board()
        gameState = GameState()
        highlightedPieces = []
        updateHighlightedPieces()
        print("Game reset")
    }
    
    func isPossibleMove(row: Int, col: Int) -> Bool {
        return gameState.possibleMoves.contains { $0.to.row == row && $0.to.col == col }
    }
    
    func isSelectedPiece(row: Int, col: Int) -> Bool {
        guard let selectedPiece = gameState.selectedPiece else { return false }
        return selectedPiece.position.row == row && selectedPiece.position.col == col
    }
    
    func isHighlightedPiece(row: Int, col: Int) -> Bool {
        return highlightedPieces.contains { $0.row == row && $0.col == col }
    }
    
    private func updatePiecesCount() {
        humanPiecesCount = board.countPieces(for: .human)
        aiPiecesCount = board.countPieces(for: .ai)
    }
}

