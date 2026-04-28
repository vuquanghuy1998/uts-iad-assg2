//
//  SettingsView.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

struct SettingsView: View {

    @StateObject private var settings = GameSettings.shared
    @Environment(\.dismiss) private var dismiss

    @State private var savedGameTime: Int = 0
    @State private var savedMaxBubbles: Int = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {

                    // MARK: - Game Time
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill").foregroundColor(.blue)
                            Text("Game Duration").font(.headline)
                            Spacer()
                            Text("\(settings.gameTime)s").font(.headline).foregroundColor(.blue)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(settings.gameTime) },
                                set: { settings.gameTime = max(GameSettings.minGameTime,
                                                               min(Int($0), GameSettings.maxGameTimeLimit)) }
                            ),
                            in: Double(GameSettings.minGameTime)...Double(GameSettings.maxGameTimeLimit),
                            step: 10
                        )
                        .tint(.blue)

                        HStack {
                            Text("\(GameSettings.minGameTime)s").font(.caption).foregroundColor(.secondary)
                            Spacer()
                            Text("\(GameSettings.maxGameTimeLimit)s").font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // MARK: - Max Bubbles
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "circle.fill").foregroundColor(.pink)
                            Text("Max Bubbles").font(.headline)
                            Spacer()
                            Text("\(settings.maxBubbles)").font(.headline).foregroundColor(.pink)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(settings.maxBubbles) },
                                set: { settings.maxBubbles = max(GameSettings.minBubbles,
                                                                  min(Int($0), GameSettings.maxBubblesLimit)) }
                            ),
                            in: Double(GameSettings.minBubbles)...Double(GameSettings.maxBubblesLimit),
                            step: 1
                        )
                        .tint(.pink)

                        HStack {
                            Text("\(GameSettings.minBubbles) bubble").font(.caption).foregroundColor(.secondary)
                            Spacer()
                            Text("\(GameSettings.maxBubblesLimit) bubbles").font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // MARK: - Save / Cancel
                    VStack(spacing: 12) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Save Settings")
                                .font(.title3).fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding()
                                .background(Color.blue)
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }

                        Button {
                            settings.gameTime   = savedGameTime
                            settings.maxBubbles = savedMaxBubbles
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.title3).fontWeight(.semibold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity).padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.top, 20)
                .frame(maxWidth: 500) // readable cap on iPad
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            savedGameTime   = settings.gameTime
            savedMaxBubbles = settings.maxBubbles
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
