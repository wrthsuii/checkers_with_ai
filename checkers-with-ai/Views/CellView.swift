//  CellView.swift
//  checkers-with-ai

import SwiftUI

struct CellView: View {
    let row: Int
    let col: Int
    let isDark: Bool
    let isPossibleMove: Bool
    let piece: Piece?
    let isSelected: Bool
    let isHighlighted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Rectangle()
            .fill(backgroundColor)
            .frame(width: 40, height: 40)
            .overlay(
                Group {
                    if let piece = piece {
                        PieceView(
                            piece: piece,
                            isSelected: isSelected,
                            isHighlighted: isHighlighted
                        )
                    } else if isPossibleMove {
                        Circle()
                            .fill(Color.green.opacity(0.8))
                            .frame(width: 15, height: 15)
                    }
                }
            )
            .onTapGesture(perform: onTap)
    }
    
    private var backgroundColor: Color {
//        if isSelected {
//            return Color.blue.opacity(0.3)
//        }
        isDark ? Color.brown : Color.beige
    }
}
