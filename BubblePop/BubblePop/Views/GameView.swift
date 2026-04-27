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
                                .onAppear { gameAreaSize = gameGeo.size }
                                .onChange(of: gameGeo.size) { _, newSize in gameAreaSize = newSize }
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

                // MARK: - Countdown overlay
                if !viewModel.isGameRunning && !viewModel.isGameOver {
                    CountdownView {
                        viewModel.startGame(screenSize: gameAreaSize)
                    }
                }
            }
            .onAppear {
                viewModel.playerName = playerName
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

// MARK: - Floating score label
struct ScorePopupLabel: View {

    let popup: ScorePopup
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        Text(popup.isCombo ? "🔥 +\(popup.points)" : "+\(popup.points)")
            .font(.system(size: popup.isCombo ? 22 : 18, weight: .bold, design: .rounded))
            .foregroundColor(popup.isCombo ? .orange : .white)
            .shadow(color: .black.opacity(0.4), radius: 2)
            .offset(y: offset)
            .opacity(opacity)
            .position(popup.position)
            .onAppear {
                withAnimation(.easeOut(duration: 0.75)) {
                    offset = -60
                    opacity = 0
                }
            }
            .allowsHitTesting(false)
    }
}

#Preview {
    WelcomeView()
}
