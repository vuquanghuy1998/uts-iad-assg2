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
    private var isPostGame: Bool { !playerName.isEmpty }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

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

                // MARK: - Scoreboard list (CF11) with swipe-to-delete
                VStack(alignment: .leading, spacing: 0) {
                    Text("High Scores")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 12)

                    if scores.isEmpty {
                        Text("No scores yet — be the first!")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        // Use a List for built-in swipe-to-delete support
                        List {
                            ForEach(Array(scores.enumerated()), id: \.offset) { index, entry in
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(rankColor(for: index))
                                            .frame(width: 32, height: 32)
                                        Text("\(index + 1)")
                                            .font(.caption).fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }

                                    Text(entry.playerName)
                                        .font(.body)
                                        .fontWeight(entry.playerName == playerName ? .bold : .regular)

                                    Spacer()

                                    Text("\(entry.score)")
                                        .font(.body).fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 4)
                                .listRowBackground(
                                    entry.playerName == playerName
                                        ? Color.blue.opacity(0.08)
                                        : Color(.systemBackground).opacity(0.01)
                                )
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { i in
                                    ScoreService.shared.deleteScore(playerName: scores[i].playerName)
                                }
                                scores.remove(atOffsets: indexSet)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .frame(maxHeight: 300)
                    }
                }
                .background(Color(.systemBackground).opacity(0.8))
                .cornerRadius(20)
                .padding(.horizontal)

                Spacer()

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
                .padding(.bottom)
            }
            .padding(.top)
        }
        .navigationTitle("Scoreboard")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isPostGame)
        .toolbar {
            // Edit button for delete mode (only when browsing, not post-game)
            if !isPostGame {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .onAppear {
            scores = ScoreService.shared.loadScores()
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

#Preview {
    WelcomeView()
}
