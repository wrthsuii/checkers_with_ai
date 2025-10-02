//  PieceView.swift
//  checkers-with-ai

import SwiftUI

struct PieceView: View {
    let piece: Piece
    let isSelected: Bool
    let isHighlighted: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorForPiece(piece))
                .frame(width: 32, height: 32)
                .shadow(color: .gray, radius: 2, x: 1, y: 1)
            
            if piece.isKing {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 12, weight: .bold))
            }
            
            if isSelected {
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 36, height: 36)
            }
            
            if isHighlighted && !isSelected {
                Circle()
                    .stroke(Color.orange, lineWidth: 2)
                    .frame(width: 34, height: 34)
            }
        }
    }
    
    private func colorForPiece(_ piece: Piece) -> Color {
        switch piece.player {
        case .human:
            return .white
        case .ai:
            return .black
        }
    }
}
