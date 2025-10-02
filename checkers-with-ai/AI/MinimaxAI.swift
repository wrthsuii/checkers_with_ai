//  MinimaxAI.swift
//  checkers-with-ai

import Foundation

class MinimaxAI {
    private let depth: Int
    
    init(depth: Int = 4) {
        self.depth = depth
    }

    func evaluate(board: Board) -> Int {
        if let gameResult = checkTerminalState(board) {
            return gameResult
        }
        
        var score = 0
        
        for piece in board.pieces {
            let pieceValue = piece.type == .man ? 100 : 300
            score += (piece.player == .ai ? pieceValue : -pieceValue)
            
            let positionBonus = evaluatePosition(piece: piece, boardSize: board.size)
            score += (piece.player == .ai ? positionBonus : -positionBonus)
        }
        
        let aiMoves = board.getAllPossibleMoves(for: .ai)
        let humanMoves = board.getAllPossibleMoves(for: .human)
        score += (aiMoves.count - humanMoves.count) * 10
        
        let aiCaptureScore = evaluateCaptureMoves(aiMoves, board: board)
        let humanCaptureScore = evaluateCaptureMoves(humanMoves, board: board)
        score += (aiCaptureScore - humanCaptureScore)
        
        return score
    }

    private func checkTerminalState(_ board: Board) -> Int? {
        let aiMoves = board.getAllPossibleMoves(for: .ai)
        let humanMoves = board.getAllPossibleMoves(for: .human)
        
        if aiMoves.isEmpty {
            return -10000
        }
        
        if humanMoves.isEmpty {
            return 10000
        }
        
        return nil
    }

    private func evaluatePosition(piece: Piece, boardSize: Int) -> Int {
        var bonus = 0
        
        if piece.type == .man {
            let progress = piece.player == .ai ? (boardSize - 1 - piece.position.row) : piece.position.row
            bonus += progress * 3
        }
        
        if piece.position.col == 0 || piece.position.col == boardSize - 1 {
            let safetyBonus = piece.type == .man ? 15 : 8
            bonus += safetyBonus
        }
        
        return bonus
    }

    private func evaluateCaptureMoves(_ moves: [Move], board: Board) -> Int {
        var captureScore = 0
        
        for move in moves where move.isCapture {
            var moveScore = 0
            
            for capturedPos in move.capturedPieces {
                if let capturedPiece = board.pieceAt(row: capturedPos.row, col: capturedPos.col) {
                    moveScore += capturedPiece.type == .man ? 40 : 120
                }
            }
            
            if move.capturedPieces.count > 1 {
                let chainBonus = move.capturedPieces.count * 20
                moveScore += chainBonus
            }
            
            captureScore += moveScore
        }
        return captureScore
    }
    
    private func minimax(board: Board, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool) -> Int {
        if let terminalScore = checkTerminalState(board) {
            return terminalScore
        }
        
        if depth == 0 {
            return evaluate(board: board)
        }
        
        var alpha = alpha
        var beta = beta
        
        if isMaximizing {
            var maxEval = Int.min
            let moves = board.getAllPossibleMoves(for: .ai)
            
            for move in moves {
                let newBoard = board.copy()
                _ = newBoard.movePiece(move)
                let eval = minimax(board: newBoard, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: false)
                maxEval = max(maxEval, eval)
                alpha = max(alpha, eval)
                
                if beta <= alpha {
                    break
                }
            }
            return maxEval
        } else {
            var minEval = Int.max
            let moves = board.getAllPossibleMoves(for: .human)
            
            for move in moves {
                let newBoard = board.copy()
                _ = newBoard.movePiece(move)
                let eval = minimax(board: newBoard, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: true)
                minEval = min(minEval, eval)
                beta = min(beta, eval)
                
                if beta <= alpha {
                    break
                }
            }
            return minEval
        }
    }
    
    func findBestMove(for board: Board) -> Move? {
        let moves = board.getAllPossibleMoves(for: .ai)
        guard !moves.isEmpty else { return nil }
        
        var bestScore = Int.min
        var bestMove: Move? = nil
        
        for move in moves {
            let newBoard = board.copy()
            _ = newBoard.movePiece(move)
            let score = minimax(board: newBoard, depth: depth - 1, alpha: Int.min, beta: Int.max, isMaximizing: false)
            
            print("Move from \(move.from) to \(move.to) -> score: \(score)")
            
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        print("AI selected move with score: \(bestScore)")
        return bestMove
    }
}
