//  ContentView.swift
//  checkers-with-ai

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        ZStack {
            Color.brown.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Checkers with AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.brown)
                
                if viewModel.gameState.gameOver {
                    VStack(spacing: 30) {
                        Text("Game Over!")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.red)
                        
                        Text(viewModel.gameState.winner == .human ? "You Won!" : "AI Won")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(viewModel.gameState.winner == .human ? .green : .black)
                        
                        Button("Play Again") {
                            viewModel.resetGame()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .padding()
                    }
                    .padding(40)
                    
                } else {
                    HStack {
                        Circle()
                            .fill(viewModel.gameState.currentPlayer == .human ? .white : .black)
                            .frame(width: 20, height: 20)
                        
                        Text(viewModel.gameState.currentPlayer == .human ? "Your Turn" : "AI is thinking...")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.gameState.currentPlayer == .human ? .white : .black)
                    }
                    .padding()
                    
                    BoardView(viewModel: viewModel)
                        .padding()
                    
                    Button("Reset Game") {
                        viewModel.resetGame()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
            .padding()
        }
    }
}
