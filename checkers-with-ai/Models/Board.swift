//  Board.swift
//  checkers-with-ai

import Foundation

struct Direction {
    let row: Int
    let col: Int
}

class Board: ObservableObject {
    @Published var pieces: [Piece] = []
    let size = 8
    
    private let allDirections = [
        Direction(row: 1, col: -1),
        Direction(row: 1, col: 1),
        Direction(row: -1, col: -1),
        Direction(row: -1, col: 1)
    ]
    
    init() {
        setupBoard()
    }
    
    private func setupBoard() {
        pieces.removeAll()
        
        for row in 0..<3 {
            for col in 0..<size {
                if (row + col) % 2 == 1 {
                    pieces.append(Piece(type: .man, player: .human, position: (row, col)))
                }
            }
        }
        
        for row in 5..<8 {
            for col in 0..<size {
                if (row + col) % 2 == 1 {
                    pieces.append(Piece(type: .man, player: .ai, position: (row, col)))
                }
            }
        }
    }
    
    func pieceAt(row: Int, col: Int) -> Piece? {
        return pieces.first { $0.position.row == row && $0.position.col == col }
    }
    
    func movePiece(_ move: Move) -> Bool {
        return movePieceByID(move)
    }
    
    func movePieceByID(_ move: Move) -> Bool {
        guard let pieceToMove = pieces.first(where: {
            $0.position.row == move.from.row && $0.position.col == move.from.col
        }) else {
            return false
        }
        
        for capturedPos in move.capturedPieces {
            pieces.removeAll {
                $0.position.row == capturedPos.row && $0.position.col == capturedPos.col
            }
            print("Captured piece at (\(capturedPos.row), \(capturedPos.col))")
        }
        
        pieces.removeAll { $0.id == pieceToMove.id }
        
        var newPiece = Piece(type: pieceToMove.type, player: pieceToMove.player, position: move.to)
        
        if newPiece.type == .man {
            if (newPiece.player == .human && move.to.row == size - 1) ||
               (newPiece.player == .ai && move.to.row == 0) {
                newPiece.type = .king
                print("Piece promoted to king")
            }
        }
        
        pieces.append(newPiece)
        objectWillChange.send()
        return true
    }
    
    func getAllPossibleMoves(for player: Player) -> [Move] {
        var moves: [Move] = []
        let playerPieces = pieces.filter { $0.player == player }
        
        for piece in playerPieces {
            let captures = getAllPossibleCaptures(for: piece)
            moves.append(contentsOf: captures)
        }
        
        if !moves.isEmpty {
            return moves
        }
        
        for piece in playerPieces {
            let regularMoves = getPossibleMoves(for: piece)
            moves.append(contentsOf: regularMoves)
        }
        return moves
    }
    
    func getAllPossibleCaptures(for piece: Piece) -> [Move] {
        var allCaptures: [Move] = []
        
        if piece.type == .man {
            findManMultipleCaptures(for: piece, currentPath: [], allCaptures: &allCaptures)
        } else {
            findKingMultipleCaptures(for: piece, currentPath: [], allCaptures: &allCaptures)
        }
        
        return allCaptures
    }
    
    private func findManMultipleCaptures(for piece: Piece, currentPath: [Move], allCaptures: inout [Move]) {
        let directions = getMoveDirections(for: piece)
        var foundCapture = false
        
        for direction in directions {
            let jumpRow = piece.position.row + direction.row
            let jumpCol = piece.position.col + direction.col
            
            let landRow = piece.position.row + 2 * direction.row
            let landCol = piece.position.col + 2 * direction.col
            
            if isValidPosition(row: jumpRow, col: jumpCol) &&
               isValidPosition(row: landRow, col: landCol) {
                
                if let jumpedPiece = pieceAt(row: jumpRow, col: jumpCol),
                   jumpedPiece.player != piece.player,
                   pieceAt(row: landRow, col: landCol) == nil {
                    
                    let alreadyCapturedInThisPath = currentPath.flatMap { $0.capturedPieces }
                        .contains { $0.row == jumpRow && $0.col == jumpCol }
                    
                    if !alreadyCapturedInThisPath {
                        let currentCapture = Move(from: piece.position, to: (landRow, landCol),
                                               capturedPieces: [(jumpRow, jumpCol)])
                        
                        let newPath = currentPath + [currentCapture]
                        
                        let tempPiece = Piece(type: piece.type, player: piece.player, position: (landRow, landCol))
                        findManMultipleCaptures(for: tempPiece, currentPath: newPath, allCaptures: &allCaptures)
                        
                        foundCapture = true
                    }
                }
            }
        }
        
        if !foundCapture && !currentPath.isEmpty {
            let allCapturedPieces = currentPath.flatMap { $0.capturedPieces }
            let fromPosition = currentPath.first!.from
            let toPosition = currentPath.last!.to
            
            let finalMove = Move(from: fromPosition, to: toPosition, capturedPieces: allCapturedPieces)
            allCaptures.append(finalMove)
        }
    }
    
    private func findKingMultipleCaptures(for piece: Piece, currentPath: [Move], allCaptures: inout [Move]) {
        let directions = allDirections
        var foundCapture = false
        
        for direction in directions {
            var currentRow = piece.position.row + direction.row
            var currentCol = piece.position.col + direction.col
            var foundOpponentPiece: Piece? = nil
            var captureRow = -1
            var captureCol = -1
            
            while isValidPosition(row: currentRow, col: currentCol) {
                if let currentPiece = pieceAt(row: currentRow, col: currentCol) {
                    if currentPiece.player != piece.player && foundOpponentPiece == nil {
                        let alreadyCaptured = currentPath.contains { pathMove in
                            pathMove.capturedPieces.contains { $0.row == currentRow && $0.col == currentCol }
                        }
                        
                        if !alreadyCaptured {
                            foundOpponentPiece = currentPiece
                            captureRow = currentRow
                            captureCol = currentCol
                        } else {
                            break
                        }
                    } else if foundOpponentPiece != nil {
                        break
                    } else {
                        break
                    }
                } else if foundOpponentPiece != nil {
                    let landRow = currentRow
                    let landCol = currentCol
                    
                    let currentCapture = Move(from: piece.position, to: (landRow, landCol),
                                           capturedPieces: [(captureRow, captureCol)])
                    
                    let newPath = currentPath + [currentCapture]
                    
                    let tempPiece = Piece(type: .king, player: piece.player, position: (landRow, landCol))
                    findKingMultipleCaptures(for: tempPiece, currentPath: newPath, allCaptures: &allCaptures)
                    
                    foundCapture = true
                    
                    currentRow += direction.row
                    currentCol += direction.col
                    continue
                }
                
                currentRow += direction.row
                currentCol += direction.col
            }
        }
        
        if !foundCapture && !currentPath.isEmpty {
            let allCapturedPieces = currentPath.flatMap { $0.capturedPieces }
            let fromPosition = currentPath.first!.from
            let toPosition = currentPath.last!.to
            
            let finalMove = Move(from: fromPosition, to: toPosition, capturedPieces: allCapturedPieces)
            allCaptures.append(finalMove)
        }
    }
    
    private func getPossibleMoves(for piece: Piece) -> [Move] {
        if piece.type == .man {
            return getManMoves(for: piece)
        } else {
            return getKingMoves(for: piece)
        }
    }
    
    private func getManMoves(for piece: Piece) -> [Move] {
        var moves: [Move] = []
        let directions = getMoveDirections(for: piece)
        
        for direction in directions {
            let newRow = piece.position.row + direction.row
            let newCol = piece.position.col + direction.col
            
            if isValidPosition(row: newRow, col: newCol) && pieceAt(row: newRow, col: newCol) == nil {
                moves.append(Move(from: piece.position, to: (newRow, newCol)))
            }
        }
        return moves
    }
    
    private func getKingMoves(for piece: Piece) -> [Move] {
        var moves: [Move] = []
        let directions = allDirections
        
        for direction in directions {
            var currentRow = piece.position.row + direction.row
            var currentCol = piece.position.col + direction.col
            
            while isValidPosition(row: currentRow, col: currentCol) {
                if pieceAt(row: currentRow, col: currentCol) == nil {
                    moves.append(Move(from: piece.position, to: (currentRow, currentCol)))
                    currentRow += direction.row
                    currentCol += direction.col
                } else {
                    break
                }
            }
        }
        return moves
    }
    
    private func getPossibleCaptures(for piece: Piece) -> [Move] {
        if piece.type == .man {
            return getManCaptures(for: piece)
        } else {
            return getKingCaptures(for: piece)
        }
    }
    
    private func getManCaptures(for piece: Piece) -> [Move] {
        var captures: [Move] = []
        let directions = getMoveDirections(for: piece)
        
        for direction in directions {
            let jumpRow = piece.position.row + direction.row
            let jumpCol = piece.position.col + direction.col
            
            let landRow = piece.position.row + 2 * direction.row
            let landCol = piece.position.col + 2 * direction.col
            
            if isValidPosition(row: jumpRow, col: jumpCol) &&
               isValidPosition(row: landRow, col: landCol) {
                
                if let jumpedPiece = pieceAt(row: jumpRow, col: jumpCol),
                   jumpedPiece.player != piece.player,
                   pieceAt(row: landRow, col: landCol) == nil {
                    
                    captures.append(Move(from: piece.position, to: (landRow, landCol), capturedPieces: [(jumpRow, jumpCol)]))
                }
            }
        }
        return captures
    }
    
    private func getKingCaptures(for piece: Piece) -> [Move] {
        var captures: [Move] = []
        let directions = allDirections
        
        for direction in directions {
            var currentRow = piece.position.row + direction.row
            var currentCol = piece.position.col + direction.col
            var foundOpponentPiece: Piece? = nil
            var captureRow = -1
            var captureCol = -1
            
            while isValidPosition(row: currentRow, col: currentCol) {
                if let currentPiece = pieceAt(row: currentRow, col: currentCol) {
                    if currentPiece.player != piece.player && foundOpponentPiece == nil {
                        foundOpponentPiece = currentPiece
                        captureRow = currentRow
                        captureCol = currentCol
                    } else if foundOpponentPiece != nil {
                        break
                    } else {
                        break
                    }
                } else if foundOpponentPiece != nil {
                    captures.append(Move(from: piece.position, to: (currentRow, currentCol),
                                       capturedPieces: [(captureRow, captureCol)]))
                }
                
                currentRow += direction.row
                currentCol += direction.col
            }
        }
        return captures
    }
    
    private func getMoveDirections(for piece: Piece) -> [Direction] {
        switch piece.type {
        case .man:
            return piece.player == .human ?
                [Direction(row: 1, col: -1), Direction(row: 1, col: 1)] :
                [Direction(row: -1, col: -1), Direction(row: -1, col: 1)]
        case .king:
            return allDirections
        }
    }
    
    private func isValidPosition(row: Int, col: Int) -> Bool {
        return row >= 0 && row < size && col >= 0 && col < size
    }
    
    func getResultOfGame() -> Player? {
        if getAllPossibleMoves(for: .ai).isEmpty { return .human }
        if getAllPossibleMoves(for: .human).isEmpty { return .ai }
        return nil // інакше гра ще триває
    }
    
    func copy() -> Board {
        let newBoard = Board()
        newBoard.pieces = self.pieces.map {
            Piece(type: $0.type, player: $0.player, position: $0.position)
        }
        return newBoard
    }
    
    func countPieces(for player: Player) -> Int {
        return pieces.filter { $0.player == player }.count
    }
}
