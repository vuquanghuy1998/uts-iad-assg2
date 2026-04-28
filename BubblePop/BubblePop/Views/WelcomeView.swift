//
//  WelcomeView.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

struct WelcomeView: View {

    @StateObject private var settings = GameSettings.shared
    @State private var playerName: String = ""
    @State private var navPath = NavigationPath()
    @State private var navigateToSettings: Bool = false
    @State private var showNameError: Bool = false

    /// Maximum characters allowed in the player name field
    private let maxNameLength = 20

    private var trimmedName: String { playerName.trimmingCharacters(in: .whitespaces) }
    private var nameIsValid: Bool { !trimmedName.isEmpty }

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {

                    // MARK: - Title
                    VStack(spacing: 6) {
                        Text("BubblePop")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Text("Pop bubbles, pop the fun!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer().frame(height: 10)

                    // MARK: - Name entry (CF1)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your Name")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Enter your name", text: $playerName)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(showNameError ? Color.red : Color.clear, lineWidth: 1.5)
                            )
                            // Enforce character limit in-line
                            .onChange(of: playerName) { _, newValue in
                                if newValue.count > maxNameLength {
                                    playerName = String(newValue.prefix(maxNameLength))
                                }
                                if !newValue.isEmpty { showNameError = false }
                            }

                        // Character counter + error hint
                        HStack {
                            if showNameError {
                                Label("Please enter your name to play.", systemImage: "exclamationmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .transition(.opacity)
                            }
                            Spacer()
                            Text("\(playerName.count)/\(maxNameLength)")
                                .font(.caption2)
                                .foregroundColor(playerName.count >= maxNameLength ? .red : .secondary)
                        }
                        .animation(.easeInOut(duration: 0.2), value: showNameError)
                    }
                    .padding(.horizontal, 40)

                    // MARK: - Start button (CF1)
                    Button {
                        if nameIsValid {
                            showNameError = false
                            navPath.append(NavDestination.game(trimmedName, UUID()))
                        } else {
                            withAnimation { showNameError = true }
                        }
                    } label: {
                        Text("Start Game")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(nameIsValid ? Color.blue : Color.gray)
                            .cornerRadius(16)
                            .padding(.horizontal, 40)
                    }

                    // MARK: - Scoreboard & Settings
                    HStack(spacing: 32) {
                        Button {
                            navigateToSettings = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                Text("Settings")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }

                        Button {
                            navPath.append(NavDestination.scoreboard("", 0))
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                    .font(.title2)
                                Text("Scores")
                                    .font(.caption)
                            }
                            .foregroundColor(.purple)
                        }
                    }
                }
                .padding()
            }
            // MARK: - Navigation destinations
            .navigationDestination(for: NavDestination.self) { destination in
                switch destination {
                case .game(let name, _):
                    GameView(playerName: name, navPath: $navPath)
                case .scoreboard(let name, let score):
                    ScoreboardView(playerName: name, finalScore: score, navPath: $navPath)
                }
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Navigation destinations enum
enum NavDestination: Hashable {
    case game(String, UUID)
    case scoreboard(String, Int)
}

#Preview {
    WelcomeView()
}
