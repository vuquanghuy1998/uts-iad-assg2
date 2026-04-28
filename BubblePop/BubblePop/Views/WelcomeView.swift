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
    @State private var knownNames: [String] = []
    @State private var showSuggestions: Bool = false

    private let maxNameLength = 50

    private var trimmedName: String { playerName.trimmingCharacters(in: .whitespaces) }
    private var nameIsValid: Bool { !trimmedName.isEmpty }

    private var filteredSuggestions: [String] {
        guard !knownNames.isEmpty else { return [] }
        let q = trimmedName.lowercased()
        if q.isEmpty { return knownNames }
        return knownNames.filter { $0.lowercased().hasPrefix(q) }
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                // Background — behind the scroll view
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // ScrollView so content is reachable in landscape / small screens
                ScrollView {
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
                        .padding(.top, 40)

                        // MARK: - Name entry + suggestions (CF1)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Your Name")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                TextField("Enter your name", text: $playerName)
                                    .onChange(of: playerName) { _, newValue in
                                        if newValue.count > maxNameLength {
                                            playerName = String(newValue.prefix(maxNameLength))
                                        }
                                        if !newValue.isEmpty { showNameError = false }
                                        showSuggestions = !filteredSuggestions.isEmpty
                                    }

                                if !knownNames.isEmpty {
                                    Button {
                                        showSuggestions.toggle()
                                        UIApplication.shared.sendAction(
                                            #selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil
                                        )
                                    } label: {
                                        Image(systemName: showSuggestions ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(showNameError ? Color.red : Color.clear, lineWidth: 1.5)
                            )

                            // Returning-player suggestions dropdown
                            if showSuggestions && !filteredSuggestions.isEmpty {
                                VStack(spacing: 0) {
                                    ForEach(filteredSuggestions, id: \.self) { name in
                                        Button {
                                            playerName = name
                                            showSuggestions = false
                                            showNameError = false
                                        } label: {
                                            HStack {
                                                Image(systemName: "person.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.caption)
                                                Text(name)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                if trimmedName.lowercased() == name.lowercased() {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.blue)
                                                        .font(.caption)
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                        }
                                        if name != filteredSuggestions.last {
                                            Divider().padding(.horizontal, 12)
                                        }
                                    }
                                }
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.12), radius: 6)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // Character counter + error hint
                            HStack {
                                if showNameError {
                                    Label("Please enter your name to play.",
                                          systemImage: "exclamationmark.circle.fill")
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
                        .animation(.easeInOut(duration: 0.18), value: showSuggestions)

                        // MARK: - Start button
                        Button {
                            if nameIsValid {
                                showNameError = false
                                showSuggestions = false
                                navPath.append(NavDestination.game(trimmedName, UUID()))
                            } else {
                                withAnimation { showNameError = true }
                            }
                        } label: {
                            Text("Start Game")
                                .font(.title2).fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding()
                                .background(nameIsValid ? Color.blue : Color.gray)
                                .cornerRadius(16)
                                .padding(.horizontal, 40)
                        }

                        // MARK: - Settings & Scoreboard
                        HStack(spacing: 32) {
                            Button { navigateToSettings = true } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "gearshape.fill").font(.title2)
                                    Text("Settings").font(.caption)
                                }
                                .foregroundColor(.blue)
                            }

                            Button {
                                navPath.append(NavDestination.scoreboard("", 0))
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "trophy.fill").font(.title2)
                                    Text("Scores").font(.caption)
                                }
                                .foregroundColor(.purple)
                            }
                        }

                        Spacer().frame(height: 20)
                    }
                    // Centre content vertically in portrait; let it scroll in landscape
                    .frame(maxWidth: 500) // cap width on iPad for readability
                    .frame(maxWidth: .infinity)
                }
            }
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
            .onAppear {
                knownNames = ScoreService.shared.allPlayerNames()
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
