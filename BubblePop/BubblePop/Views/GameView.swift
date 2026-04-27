//
//  GameView.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

struct GameView: View {
    
    let playerName: String
    
    @StateObject private var viewModel = GameViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToScoreboard: Bool = false
    @State private var gameAreaSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                // MARK: - Background
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Header
                    HStack {
                        // Time left
                        VStack {
                            Text("Time Left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.timeLeft)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(viewModel.timeLeft <= 10 ? .red : .primary)
                        }
                        
                        Spacer()
                        
                        // Current score
                        VStack {
                            Text("Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.score)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        // High score
                        VStack {
                            Text("Best")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.highestScore)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.8))
                    
                    // MARK: - Game area
                    // Bubbles are positioned relative to this ZStack's coordinate space,
                    // so we measure its actual size and pass that to the view model.
                    ZStack {
                        // Invisible size reader — fills the game area and reports its size
                        GeometryReader { gameGeo in
                            Color.clear
                                .onAppear {
                                    gameAreaSize = gameGeo.size
                                }
                                .onChange(of: gameGeo.size) { _, newSize in
                                    gameAreaSize = newSize
                                }
                        }
                        
                        // Bubbles
                        ForEach(viewModel.bubbles) { bubble in
                            Circle()
                                .fill(bubble.color)
                                .frame(width: bubble.radius * 2,
                                       height: bubble.radius * 2)
                                .position(bubble.position)
                                .onTapGesture {
                                    viewModel.popBubble(bubble)
                                }
                                .shadow(color: bubble.color.opacity(0.4),
                                        radius: 4, x: 0, y: 2)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // MARK: - Countdown overlay
                if !viewModel.isGameRunning && !viewModel.isGameOver {
                    CountdownView {
                        viewModel.startGame(screenSize: gameAreaSize)
                    }
                }
            }
            // Start countdown when view appears
            .onAppear {
                viewModel.playerName = playerName
            }
            // Navigate to scoreboard when game ends
            .onChange(of: viewModel.isGameOver) { _, isOver in
                if isOver {
                    navigateToScoreboard = true
                }
            }
            .navigationDestination(isPresented: $navigateToScoreboard) {
                ScoreboardView(
                    playerName: playerName,
                    finalScore: viewModel.score
                )
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Quit")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Countdown View
struct CountdownView: View {
    
    let onComplete: () -> Void
    @State private var count: Int = 3
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(opacity)
                } else {
                    Text("GO!")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .opacity(opacity)
                }
            }
        }
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        // Count 3, 2, 1, GO then start
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.3)) {
                opacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if count > 0 {
                    count -= 1
                    withAnimation(.easeInOut(duration: 0.3)) {
                        opacity = 1.0
                    }
                } else {
                    timer.invalidate()
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GameView(playerName: "Test Player")
    }
}
