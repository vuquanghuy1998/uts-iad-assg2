//
//  ContentView.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var settings = GameSettings.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // MARK: - Game Time Setting
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                        Text("Game Duration")
                            .font(.headline)
                        Spacer()
                        Text("\(settings.gameTime)s")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { Double(settings.gameTime) },
                            set: { settings.gameTime = Int($0) }
                        ),
                        in: Double(GameSettings.minGameTime)...Double(GameSettings.maxGameTime),
                        step: 10
                    )
                    .tint(.blue)
                    
                    HStack {
                        Text("\(GameSettings.minGameTime)s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(GameSettings.maxGameTime)s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.8))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // MARK: - Max Bubbles Setting
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.pink)
                        Text("Max Bubbles")
                            .font(.headline)
                        Spacer()
                        Text("\(settings.maxBubbles)")
                            .font(.headline)
                            .foregroundColor(.pink)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { Double(settings.maxBubbles) },
                            set: { settings.maxBubbles = Int($0) }
                        ),
                        in: Double(GameSettings.minBubbles)...Double(GameSettings.maxBubbles),
                        step: 1
                    )
                    .tint(.pink)
                    
                    HStack {
                        Text("\(GameSettings.minBubbles) bubble")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(GameSettings.maxBubbles) bubbles")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.8))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // MARK: - Save button
                Button {
                    dismiss()
                } label: {
                    Text("Save Settings")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
