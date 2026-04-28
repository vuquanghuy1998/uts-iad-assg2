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
    /// Guards the CountdownView so it only appears after the game area has been measured,
    /// preventing startGame from receiving a zero-sized screenSize.
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
                    GameHeaderView(viewModel: viewModel)

                    // MARK: - Game area
                    ZStack {
                        // Invisible geometry reader — captures the true game-area size
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

                        // Bubbles
                        ForEach(viewModel.bubbles) { bubble in
                            BubbleView(bubble: bubble)
                                .onTapGesture { viewModel.popBubble(bubble) }
                        }

                        // Floating score popups
                        ForEach(viewModel.scorePopups) { popup in
                            ScorePopupLabel(popup: popup)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // MARK: - Countdown overlay
                // Only shown once the game area size is known and we are not yet running.
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
                    navPath.append(NavDestination.scoreboard(playerName, viewModel.score))
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
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

// MARK: - Header view
/// Shows Time Left, current Score (with a flash on change), and Best score.
/// Also displays an animated combo badge when the player is on a streak.
struct GameHeaderView: View {

    @ObservedObject var viewModel: GameViewModel
    @State private var scoreScale: CGFloat = 1.0

    var body: some View {
        HStack {
            // Time left
            VStack(spacing: 2) {
                Text("Time Left")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewModel.timeLeft)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.timeLeft <= 10 ? .red : .primary)
            }

            Spacer()

            // Score — flashes and scales up on each new point
            VStack(spacing: 2) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewModel.score)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .scaleEffect(scoreScale)
                    .onChange(of: viewModel.scoreDidChange) { _, _ in
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                            scoreScale = 1.35
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                scoreScale = 1.0
                            }
                        }
                    }

                // Combo badge — visible whenever the player has 2+ consecutive pops
                if viewModel.comboCount >= 2 {
                    Text("🔥 ×\(viewModel.comboCount) Combo!")
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundColor(.orange)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.comboCount)

            Spacer()

            // Best score (EF3)
            VStack(spacing: 2) {
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
        .background(Color(.systemBackground).opacity(0.85))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Individual bubble view
/// Renders a bubble as a radial-gradient circle with a gloss highlight,
/// and plays a pop animation (scale + fade) when `bubble.isPopped` becomes true.
struct BubbleView: View {

    let bubble: Bubble

    var body: some View {
        ZStack {
            // Base fill — radial gradient gives a 3-D sheen
            Circle()
                .fill(
                    RadialGradient(
                        colors: [bubble.color.opacity(0.6), bubble.color],
                        center: .init(x: 0.35, y: 0.3),
                        startRadius: 2,
                        endRadius: bubble.radius * 1.8
                    )
                )

            // Gloss highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.55), .clear],
                        center: .init(x: 0.38, y: 0.28),
                        startRadius: 1,
                        endRadius: bubble.radius * 0.8
                    )
                )
        }
        .frame(width: bubble.radius * 2, height: bubble.radius * 2)
        .scaleEffect(bubble.isPopped ? 1.5 : 1.0)
        .opacity(bubble.isPopped ? 0.0 : 1.0)
        .animation(
            .spring(response: 0.22, dampingFraction: 0.45),
            value: bubble.isPopped
        )
        .shadow(color: bubble.color.opacity(0.45), radius: 5, x: 0, y: 3)
        .position(bubble.position)
        .allowsHitTesting(!bubble.isPopped)
    }
}

// MARK: - Countdown overlay (EF2a)
struct CountdownView: View {

    let onComplete: () -> Void
    @State private var count: Int = 3
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
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
        .task { await runCountdown() }
    }

    private func runCountdown() async {
        for n in stride(from: 3, through: 0, by: -1) {
            count = n
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0; opacity = 1.0
            }
            try? await Task.sleep(nanoseconds: 700_000_000)
            withAnimation(.easeIn(duration: 0.25)) {
                scale = 1.3; opacity = 0.0
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
            scale = 0.5
        }
        onComplete()
    }
}

// MARK: - Floating score label (EF2c)
struct ScorePopupLabel: View {

    let popup: ScorePopup
    @State private var offset: CGFloat = -40
    @State private var opacity: Double = 1.0

    var body: some View {
        Text(popup.isCombo ? "🔥 +\(popup.points)" : "+\(popup.points)")
            .font(.system(size: popup.isCombo ? 28 : 24, weight: .heavy, design: .rounded))
            .foregroundColor(popup.isCombo ? .orange : .white)
            .overlay(
                Text(popup.isCombo ? "🔥 +\(popup.points)" : "+\(popup.points)")
                    .font(.system(size: popup.isCombo ? 28 : 24, weight: .heavy, design: .rounded))
                    .foregroundColor(popup.isCombo ? .brown.opacity(0.6) : .black.opacity(0.5))
                    .blur(radius: 0.5)
            )
            .shadow(color: .black.opacity(0.55), radius: 3, x: 0, y: 2)
            .offset(y: offset)
            .opacity(opacity)
            .position(popup.position)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    offset = -110
                    opacity = 0
                }
            }
            .allowsHitTesting(false)
    }
}

#Preview {
    WelcomeView()
}
