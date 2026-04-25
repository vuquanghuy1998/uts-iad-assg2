//
//  ScoreService.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import Foundation

class ScoreService {
    
    // The key we use to save/load from UserDefaults
    private let scoresKey = "savedScores"
    
    // Shared instance - one ScoreService used across the whole app
    static let shared = ScoreService()
    private init() {}
    
    // MARK: - Load scores
    func loadScores() -> [Score] {
        guard let data = UserDefaults.standard.data(forKey: scoresKey),
              let decoded = try? JSONDecoder().decode([Score].self, from: data)
        else {
            return []
        }
        return decoded.sorted { $0.score > $1.score }
    }
    
    // MARK: - Save score
    func saveScore(playerName: String, score: Int) {
        var scores = loadScores()
        
        // If player already exists, only update if new score is higher
        if let index = scores.firstIndex(where: {
            $0.playerName.lowercased() == playerName.lowercased()
        }) {
            if score > scores[index].score {
                scores[index] = Score(playerName: playerName, score: score)
            }
        } else {
            // New player, just append
            scores.append(Score(playerName: playerName, score: score))
        }
        
        // Encode and save back to UserDefaults
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: scoresKey)
        }
    }
    
    // MARK: - Get highest score
    func highestScore() -> Int {
        return loadScores().first?.score ?? 0
    }
}
