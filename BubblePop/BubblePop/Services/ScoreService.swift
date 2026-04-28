//
//  ScoreService.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import Foundation

class ScoreService {

    private let scoresKey = "savedScores"

    static let shared = ScoreService()
    private init() {}

    // MARK: - Load scores (sorted highest first)
    func loadScores() -> [Score] {
        guard let data = UserDefaults.standard.data(forKey: scoresKey),
              let decoded = try? JSONDecoder().decode([Score].self, from: data)
        else { return [] }
        return decoded.sorted { $0.score > $1.score }
    }

    // MARK: - Save score (only updates if the new score beats the existing one)
    func saveScore(playerName: String, score: Int) {
        var scores = loadScores()
        if let index = scores.firstIndex(where: {
            $0.playerName.lowercased() == playerName.lowercased()
        }) {
            if score > scores[index].score {
                scores[index] = Score(playerName: playerName, score: score)
            }
        } else {
            scores.append(Score(playerName: playerName, score: score))
        }
        persist(scores)
    }

    // MARK: - Delete a single player's score by their name
    func deleteScore(playerName: String) {
        let updated = loadScores().filter {
            $0.playerName.lowercased() != playerName.lowercased()
        }
        persist(updated)
    }

    // MARK: - All known player names (for the name-picker on the welcome screen)
    func allPlayerNames() -> [String] {
        loadScores().map { $0.playerName }
    }

    // MARK: - Highest score across all players
    func highestScore() -> Int {
        loadScores().first?.score ?? 0
    }

    // MARK: - Private helper
    private func persist(_ scores: [Score]) {
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: scoresKey)
        }
    }
}
