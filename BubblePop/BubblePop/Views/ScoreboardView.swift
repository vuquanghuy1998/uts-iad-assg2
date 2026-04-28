//
//  ScoreboardView.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

// MARK: - Main view
struct ScoreboardView: View {

    let playerName: String
    let finalScore: Int
    @Binding var navPath: NavigationPath

    @State private var scores: [Score] = []
    @State private var pendingDeleteName: String? = nil
    @State private var isEditing: Bool = false

    private var isPostGame: Bool { !playerName.isEmpty }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Post-game result card
                    if isPostGame {
                        ResultCard(
                            playerName: playerName,
                            finalScore: finalScore,
                            isNewHighScore: isNewHighScore
                        )
                    }

                    // High scores list
                    ScoreList(
                        scores: scores,
                        highlightName: playerName,
                        isEditing: isEditing,
                        onDelete: { name in pendingDeleteName = name }
                    )

                    // Action buttons
                    ActionButtons(
                        isPostGame: isPostGame,
                        onPlayAgain: {
                            navPath = NavigationPath()
                            navPath.append(NavDestination.game(playerName, UUID()))
                        },
                        onHome: {
                            navPath = NavigationPath()
                        }
                    )

                    Spacer().frame(height: 20)
                }
                .padding(.top)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Scoreboard")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isPostGame)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
                .disabled(scores.isEmpty)
            }
        }
        .onAppear {
            scores = ScoreService.shared.loadScores()
        }
        .onChange(of: scores) { _, newScores in
            if newScores.isEmpty { isEditing = false }
        }
        // Confirmation alert — shown for both minus-button and swipe-to-delete
        .alert("Delete Score?", isPresented: Binding(
            get: { pendingDeleteName != nil },
            set: { if !$0 { pendingDeleteName = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let name = pendingDeleteName {
                    ScoreService.shared.deleteScore(playerName: name)
                    scores = ScoreService.shared.loadScores()
                }
                pendingDeleteName = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteName = nil
            }
        } message: {
            if let name = pendingDeleteName {
                Text("Remove \(name)'s score from the leaderboard? This cannot be undone.")
            }
        }
    }

    private var isNewHighScore: Bool {
        guard isPostGame, finalScore > 0 else { return false }
        let saved = scores.first { $0.playerName.lowercased() == playerName.lowercased() }
        return saved?.score == finalScore && finalScore >= (scores.first?.score ?? 0)
    }
}

// MARK: - Result card
private struct ResultCard: View {
    let playerName: String
    let finalScore: Int
    let isNewHighScore: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text("Game Over!")
                .font(.system(size: 36, weight: .bold, design: .rounded))

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

            if isNewHighScore {
                HStack {
                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
                    Text("New High Score!")
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

// MARK: - Score list
private struct ScoreList: View {
    let scores: [Score]
    let highlightName: String
    let isEditing: Bool
    let onDelete: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("High Scores")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 10)

            if scores.isEmpty {
                Text("No scores yet — be the first!")
                    .foregroundColor(.secondary)
                    .padding([.horizontal, .bottom])
            } else {
                ForEach(Array(scores.enumerated()), id: \.offset) { index, entry in
                    ScoreRow(
                        index: index,
                        entry: entry,
                        highlightName: highlightName,
                        rankColor: rankColor(for: index),
                        isEditing: isEditing,
                        onDelete: { onDelete(entry.playerName) },
                        onSwipeDelete: { onDelete(entry.playerName) }
                    )
                    if index < scores.count - 1 {
                        Divider().padding(.horizontal)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(20)
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }

    private func rankColor(for index: Int) -> Color {
        switch index {
        case 0:  return .yellow
        case 1:  return .gray
        case 2:  return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }
}

// MARK: - Score row
private struct ScoreRow: View {
    let index: Int
    let entry: Score
    let highlightName: String
    let rankColor: Color
    let isEditing: Bool
    let onDelete: () -> Void
    let onSwipeDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if isEditing {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }

            RankBadge(rank: index + 1, color: rankColor)

            let isCurrent = entry.playerName == highlightName
            Text(entry.playerName)
                .font(.body)
                .fontWeight(isCurrent ? .bold : .regular)
                .lineLimit(1)

            Spacer()

            let scoreStr = "\(entry.score)"
            Text(scoreStr)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            entry.playerName == highlightName
                ? Color.blue.opacity(0.08)
                : Color.clear
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onSwipeDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Rank badge
private struct RankBadge: View {
    let rank: Int
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
            let label = "\(rank)"
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Action buttons
private struct ActionButtons: View {
    let isPostGame: Bool
    let onPlayAgain: () -> Void
    let onHome: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if isPostGame {
                ScoreboardButton(
                    title: "Play Again",
                    foreground: .white,
                    background: Color.blue,
                    action: onPlayAgain
                )
            }
            ScoreboardButton(
                title: "Home",
                foreground: .blue,
                background: Color.blue.opacity(0.1),
                action: onHome
            )
        }
    }
}

// MARK: - Reusable full-width button
private struct ScoreboardButton: View {
    let title: String
    let foreground: Color
    let background: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(foreground)
                .frame(maxWidth: .infinity)
                .padding()
                .background(background)
                .cornerRadius(16)
                .padding(.horizontal)
        }
    }
}

#Preview {
    WelcomeView()
}
