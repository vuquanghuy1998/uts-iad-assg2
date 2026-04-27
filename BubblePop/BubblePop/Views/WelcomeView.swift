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
                    Text("BubblePop")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)

                    Text("Pop bubbles, pop the fun!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer().frame(height: 20)

                    // MARK: - Name entry
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Name")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Enter your name", text: $playerName)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                    .padding(.horizontal, 40)

                    // MARK: - Start button
                    Button {
                        navPath.append(NavDestination.game(playerName.trimmingCharacters(in: .whitespaces)))
                    } label: {
                        Text("Start Game")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(playerName.trimmingCharacters(
                                in: .whitespaces).isEmpty ? Color.gray : Color.blue
                            )
                            .cornerRadius(16)
                            .padding(.horizontal, 40)
                    }
                    .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty)

                    // MARK: - Settings button
                    Button {
                        navigateToSettings = true
                    } label: {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            // MARK: - Navigation destinations
            .navigationDestination(for: NavDestination.self) { destination in
                switch destination {
                case .game(let name):
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
    case game(String)
    case scoreboard(String, Int)
}

#Preview {
    WelcomeView()
}
