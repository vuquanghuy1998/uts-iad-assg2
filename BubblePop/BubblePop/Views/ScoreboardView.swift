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
    /// Set when the user taps the minus button or swipes a row — triggers the confirmation alert.
    @State private var pendingDeleteName: String? = nil
    /// Toggled by the Edit / Done button in the toolbar.
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

                    // MARK: - Player result card (post-game only)
                    if isPostGame {
                        VStack(spacing: 8) {
                            Text("Game Over!")
                                .font(.system(size: 36, weight: .bold, design: .rounded))

                            Text(playerName)
                                .font(.title2).fontWeight(.semibold)
                                .foregroundColor(.blue)

                            Text("Your Score")
                                .font(.caption).foregroundColor(.secondary)

                            Text("\(finalScore)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)

                            if isNewHighScore {
                                HStack {
                                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
                                    Text("New High Score!").fontWeight(.semibold).foregroundColor(.yellow)
                                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }

                    // MARK: - High scores list (CF11)
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
                                HStack(spacing: 12) {

                                    // Red minus button shown in edit mode
                                    if isEditing {
                                        Button {
                                            pendingDeleteName = entry.playerName
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.title3)
                                        }
                                        .transition(.move(edge: .leading).combined(with: .opacity))
                                    }

                                    RankBadge(rank: index + 1, color: rankColor(for: index))

                                    Text(entry.playerName)
                                        .font(.body)
                                        .fontWeight(entry.playerName == playerName ? .bold : .regular)
                                        .lineLimit(1)

                                    Spacer()

                                    Text("\(entry.score)")
                                        .font(.body).fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background(
                                    entry.playerName == playerName
                                        ? Color.blue.opacity(0.08)
                                        : Color.clear
                                )
                                // Swipe-to-delete also available (requires tap to confirm)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        pendingDeleteName = entry.playerName
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }

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

                    // MARK: - Action buttons
                    VStack(spacing: 12) {
                        if isPostGame {
                            Button {
                                navPath = NavigationPath()
                                navPath.append(NavDestination.game(playerName, UUID()))
                            } label: {
                                Text("Play Again")
                                    .font(.title3).fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity).padding()
                                    .background(Color.blue)
                                    .cornerRadius(16)
                                    .padding(.horizontal)
                            }
                        }

                        Button {
                            navPath = NavigationPath()
                        } label: {
                            Text("Home")
                                .font(.title3).fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity).padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                    }

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
            // Edit / Done button — always shown so users can manage scores
            // whether they arrived post-game or browsed from the home screen.
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
        // Exit edit mode automatically when the list becomes empty
        .onChange(of: scores) { _, newScores in
            if newScores.isEmpty { isEditing = false }
        }
        // MARK: - Delete confirmation alert
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

    // MARK: - Helpers
    private var isNewHighScore: Bool {
        guard isPostGame, finalScore > 0 else { return false }
        let saved = scores.first { $0.playerName.lowercased() == playerName.lowercased() }
        return saved?.score == finalScore && finalScore >= (scores.first?.score ?? 0)
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

// MARK: - Rank badge helper
/// Extracted into its own view so the Swift type-checker doesn't time out
/// when inferring the surrounding ForEach expression.
private struct RankBadge: View {
    let rank: Int
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    WelcomeView()
}
