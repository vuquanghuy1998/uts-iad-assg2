//
//  GameSettings.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import Foundation
import Combine

class GameSettings: ObservableObject {

    // Keys for UserDefaults
    private let gameTimeKey = "gameTime"
    private let maxBubblesKey = "maxBubbles"

    // MARK: - Constraints (hard limits, never change)
    static let minGameTime = 10
    static let maxGameTimeLimit = 300
    static let minBubbles = 1
    static let maxBubblesLimit = 30

    // MARK: - Game time (default 60 seconds)
    // didSet only persists — clamping is done at the point of assignment
    // (writing back to self inside didSet causes infinite recursion).
    @Published var gameTime: Int {
        didSet { UserDefaults.standard.set(gameTime, forKey: gameTimeKey) }
    }

    // MARK: - Max bubbles (default 15)
    @Published var maxBubbles: Int {
        didSet { UserDefaults.standard.set(maxBubbles, forKey: maxBubblesKey) }
    }

    // Shared instance
    static let shared = GameSettings()
    private init() {
        let savedTime = UserDefaults.standard.object(forKey: "gameTime") as? Int ?? 60
        let savedBubbles = UserDefaults.standard.object(forKey: "maxBubbles") as? Int ?? 15
        // Clamp on load in case stored values are out of range
        self.gameTime = max(Self.minGameTime, min(savedTime, Self.maxGameTimeLimit))
        self.maxBubbles = max(Self.minBubbles, min(savedBubbles, Self.maxBubblesLimit))
    }
}
