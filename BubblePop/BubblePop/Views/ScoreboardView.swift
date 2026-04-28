//
//  ScoreboardView.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

struct ScoreboardView: View {

    let playerName: String
    let finalScore: Int
    @Binding var navPath: NavigationPath

    @State private var scores: [Score] = []

    var body: some View {
        ZStack {

            // MARK: - Background
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {

                // MARK: - Player result card
                VStack(spacing: 8) {
                    Text("Game Over!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(playerName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    Text("Your Score")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(finalScore)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)

                    if finalScore == scores.first?.score && finalScore > 0 {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            Text("New High Score!")
                                .fontWeight(.semibold)
                                .foregroundColor(.yellow)
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground).opacity(0.8))
                .cornerRadius(20)
                .padding(.horizontal)

                // MARK: - Scoreboard list
                VStack(alignment: .leading, spacing: 12) {
                    Text("High Scores")
                        .font(.headline)
                        .padding(.horizontal)

                    if scores.isEmpty {
                        Text("No scores yet")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(Array(scores.enumerated()), id: \.offset) { index, entry in
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(rankColor(for: index))
                                        .frame(width: 32, height: 32)
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }

                                Text(entry.playerName)
                                    .font(.body)
                                    .fontWeight(entry.playerName == playerName ? .bold : .regular)

                                Spacer()

                                Text("\(entry.score)")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(
                                entry.playerName == playerName ?
                                Color.blue.opacity(0.1) : Color.clear
                            )
                            .cornerRadius(10)
                            .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.vertical)
                .background(Color(.systemBackground).opacity(0.8))
                .cornerRadius(20)
                .padding(.horizontal)

                Spacer()

                // MARK: - Action buttons
                VStack(spacing: 12) {

                    // Play Again — pop back to GameView by keeping only the game entry
                    Button {
                        // Remove scoreboard from path, leaving the game destination,
                        // which creates a fresh GameView with a new countdown
                        navPath = NavigationPath()
                        navPath.append(NavDestination.game(playerName, UUID()))
                    } label: {
                        Text("Play Again")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }

                    // Home — clear entire stack, back to WelcomeView
                    Button {
                        navPath = NavigationPath()
                    } label: {
                        Text("Home")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .padding(.top)
        }
        .navigationTitle("Scoreboard")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            scores = ScoreService.shared.loadScores()
        }
    }

    private func rankColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .blue
        }
    }
}

#Preview {
    WelcomeView()
}
