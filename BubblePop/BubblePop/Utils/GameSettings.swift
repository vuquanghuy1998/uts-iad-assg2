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
    
    // Constraints
    static let minGameTime = 10
    static let maxGameTime = 300
    static let minBubbles = 1
    static let maxBubbles = 30
    
    // MARK: - Game time (default 60 seconds)
    @Published var gameTime: Int {
        didSet {
            // Clamp to valid range before saving
            gameTime = max(GameSettings.minGameTime,
                          min(gameTime, GameSettings.maxGameTime))
            UserDefaults.standard.set(gameTime, forKey: gameTimeKey)
        }
    }
    
    // MARK: - Max bubbles (default 15)
    @Published var maxBubbles: Int {
        didSet {
            // Clamp to valid range before saving
            maxBubbles = max(GameSettings.minBubbles,
                            min(maxBubbles, GameSettings.maxBubbles))
            UserDefaults.standard.set(maxBubbles, forKey: maxBubblesKey)
        }
    }
    
    // Shared instance
    static let shared = GameSettings()
    private init() {
        // Load saved values or use defaults
        self.gameTime = UserDefaults.standard.object(forKey: "gameTime") as? Int ?? 60
        self.maxBubbles = UserDefaults.standard.object(forKey: "maxBubbles") as? Int ?? 15
    }
}
