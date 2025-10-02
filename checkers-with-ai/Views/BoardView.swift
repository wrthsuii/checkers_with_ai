//  BoardView.swift
//  checkers-with-ai

import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<viewModel.board.size, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<viewModel.board.size, id: \.self) { col in
                        let isDark = (row + col) % 2 == 1
                        let piece = viewModel.board.pieceAt(row: row, col: col)
                        let isSelected = viewModel.isSelectedPiece(row: row, col: col)
                        let isPossibleMove = viewModel.isPossibleMove(row: row, col: col)
                        let isHighlighted = viewModel.isHighlightedPiece(row: row, col: col) // НОВЕ
                        
                        CellView(
                            row: row,
                            col: col,
                            isDark: isDark,
                            isPossibleMove: isPossibleMove,
                            piece: piece,
                            isSelected: isSelected,
                            isHighlighted: isHighlighted // НОВЕ
                        ) {
                            viewModel.selectPiece(at: row, col: col)
                        }
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 2)
        )
    }
}
