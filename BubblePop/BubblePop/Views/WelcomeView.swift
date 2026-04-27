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
    @State private var navigateToGame: Bool = false
    @State private var navigateToSettings: Bool = false
    
    var body: some View {
        NavigationStack {
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
                    
                    Text("Pop bubbles, drop the fun!")
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
                        navigateToGame = true
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
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(playerName: playerName.trimmingCharacters(in: .whitespaces))
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
