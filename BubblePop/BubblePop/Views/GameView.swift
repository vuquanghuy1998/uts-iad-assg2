//
//  GameView.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

struct GameView: View {

    let playerName: String
    @Binding var navPath: NavigationPath

    @StateObject private var viewModel = GameViewModel()
    @State private var gameAreaSize: CGSize = .zero
    @State private var gameAreaReady: Bool = false

    var body: some View {
        GeometryReader { _ in
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
                    ZStack {
                        GeometryReader { gameGeo in
                            Color.clear
                                .onAppear {
                                    gameAreaSize = gameGeo.size
                                    gameAreaReady = true
                                }
                                .onChange(of: gameGeo.size) { _, newSize in
                                    gameAreaSize = newSize
                                    gameAreaReady = true
                                }
                        }

                        // Bubbles with pop animation
                        ForEach(viewModel.bubbles) { bubble in
                            Circle()
                                .fill(bubble.color)
                                .frame(width: bubble.radius * 2,
                                       height: bubble.radius * 2)
                                .scaleEffect(bubble.isPopped ? 1.4 : 1.0)
                                .opacity(bubble.isPopped ? 0.0 : 1.0)
                                .animation(
                                    .spring(response: 0.25, dampingFraction: 0.5),
                                    value: bubble.isPopped
                                )
                                .position(bubble.position)
                                .onTapGesture {
                                    viewModel.popBubble(bubble)
                                }
                                .shadow(color: bubble.color.opacity(0.4),
                                        radius: 4, x: 0, y: 2)
                        }

                        // Floating score popups
                        ForEach(viewModel.scorePopups) { popup in
                            ScorePopupLabel(popup: popup)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // MARK: - Countdown overlay (only after game area is measured)
                if gameAreaReady && !viewModel.isGameRunning && !viewModel.isGameOver {
                    CountdownView {
                        viewModel.startGame(screenSize: gameAreaSize)
                    }
                }
            }
            .onAppear {
                viewModel.playerName = playerName
                viewModel.restartGame()
            }
            .onChange(of: viewModel.isGameOver) { _, isOver in
                if isOver {
                    // Push scoreboard onto the shared nav path
                    navPath.append(NavDestination.scoreboard(playerName, viewModel.score))
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Quit: pop back to Welcome by clearing the path
                        navPath = NavigationPath()
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
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            Group {
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                } else {
                    Text("GO!")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .task {
            await runCountdown()
        }
    }

    private func runCountdown() async {
        // 3... 2... 1... GO!
        for n in stride(from: 3, through: 0, by: -1) {
            count = n
            // Pop in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            // Hold for 0.7s then fade out
            try? await Task.sleep(nanoseconds: 700_000_000)
            withAnimation(.easeIn(duration: 0.25)) {
                scale = 1.3
                opacity = 0.0
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
            // Reset for next number
            scale = 0.5
        }
        onComplete()
    }
}

// MARK: - Floating score label
struct ScorePopupLabel: View {

    let popup: ScorePopup
    @State private var offset: CGFloat = -40   // start already above the bubble centre
    @State private var opacity: Double = 1.0

    var body: some View {
        Text(popup.isCombo ? "🔥 +\(popup.points)" : "+\(popup.points)")
            .font(.system(size: popup.isCombo ? 28 : 24, weight: .heavy, design: .rounded))
            .foregroundColor(popup.isCombo ? .orange : .white)
            // Thin stroke border for legibility
            .overlay(
                Text(popup.isCombo ? "🔥 +\(popup.points)" : "+\(popup.points)")
                    .font(.system(size: popup.isCombo ? 28 : 24, weight: .heavy, design: .rounded))
                    .foregroundColor(popup.isCombo ? .brown.opacity(0.6) : .black.opacity(0.5))
                    .blur(radius: 0.5)
            )
            // Drop shadow
            .shadow(color: .black.opacity(0.55), radius: 3, x: 0, y: 2)
            .offset(y: offset)
            .opacity(opacity)
            .position(popup.position)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    offset = -110    // floats ~70pt further up from starting offset
                    opacity = 0
                }
            }
            .allowsHitTesting(false)
    }
}

#Preview {
    WelcomeView()
}
