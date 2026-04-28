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
    @Published var gameTime: Int {
        didSet {
            gameTime = max(GameSettings.minGameTime,
                          min(gameTime, GameSettings.maxGameTimeLimit))
            UserDefaults.standard.set(gameTime, forKey: gameTimeKey)
        }
    }

    // MARK: - Max bubbles (default 15)
    @Published var maxBubbles: Int {
        didSet {
            maxBubbles = max(GameSettings.minBubbles,
                            min(maxBubbles, GameSettings.maxBubblesLimit))
            UserDefaults.standard.set(maxBubbles, forKey: maxBubblesKey)
        }
    }

    // Shared instance
    static let shared = GameSettings()
    private init() {
        self.gameTime = UserDefaults.standard.object(forKey: "gameTime") as? Int ?? 60
        self.maxBubbles = UserDefaults.standard.object(forKey: "maxBubbles") as? Int ?? 15
    }
}
