//
//  GameViewModel.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    
    // MARK: - Published properties (views watch these)
    @Published var bubbles: [Bubble] = []
    @Published var score: Int = 0
    @Published var timeLeft: Int = 0
    @Published var isGameOver: Bool = false
    @Published var isGameRunning: Bool = false
    @Published var scorePopups: [ScorePopup] = []
    
    // MARK: - Private properties
    private var timer: AnyCancellable?
    private var lastPoppedColor: BubbleColor? = nil
    private var screenSize: CGSize = .zero
    private let settings = GameSettings.shared
    private let scoreService = ScoreService.shared
    
    // MARK: - Player info
    var playerName: String = ""
    
    // MARK: - Highest score during gameplay
    var highestScore: Int {
        scoreService.highestScore()
    }
    
    // MARK: - Start game
    func startGame(screenSize: CGSize) {
        self.screenSize = screenSize
        self.score = 0
        self.timeLeft = settings.gameTime
        self.bubbles = []
        self.isGameOver = false
        self.isGameRunning = true
        self.lastPoppedColor = nil
        
        // Generate initial bubbles
        spawnBubbles()
        
        // Start the countdown timer
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.onTick()
            }
    }
    
    // MARK: - Every second tick
    private func onTick() {
        guard timeLeft > 0 else {
            endGame()
            return
        }
        
        timeLeft -= 1
        refreshBubbles()
        
        if timeLeft == 0 {
            endGame()
        }
    }
    
    // MARK: - Refresh bubbles every second
    private func refreshBubbles() {
        // Randomly remove some existing bubbles
        let removeCount = Int.random(in: 0...max(0, bubbles.count))
        let shuffled = bubbles.shuffled()
        bubbles = Array(shuffled.dropFirst(removeCount))
        
        // Spawn new bubbles to fill up
        spawnBubbles()
    }
    
    // MARK: - Spawn new bubbles
    private func spawnBubbles() {
        let maxBubbles = settings.maxBubbles
        let currentCount = bubbles.count
        
        guard currentCount < maxBubbles else { return }
        
        // Random number of new bubbles to add
        let spotsAvailable = maxBubbles - currentCount
        let newCount = Int.random(in: 0...spotsAvailable)
        
        let newBubbles = BubbleGenerator.generateBubbles(
            count: newCount,
            existingBubbles: bubbles,
            screenSize: screenSize
        )
        
        bubbles.append(contentsOf: newBubbles)
    }
    
    // MARK: - Pop a bubble
    func popBubble(_ bubble: Bubble) {
        guard let index = bubbles.firstIndex(where: { $0.id == bubble.id }),
              !bubbles[index].isPopped
        else { return }

        // Calculate points with combo multiplier before marking popped
        var pointsEarned = bubble.points
        let isCombo = lastPoppedColor == bubble.bubbleColor
        if isCombo {
            pointsEarned = Int((Double(bubble.points) * 1.5).rounded())
        }
        score += pointsEarned
        lastPoppedColor = bubble.bubbleColor

        // Show score popup
        let popup = ScorePopup(
            id: bubble.id,
            points: pointsEarned,
            isCombo: isCombo,
            position: bubble.position
        )
        scorePopups.append(popup)

        // Mark as popped — drives the shrink/fade animation in the view
        bubbles[index].isPopped = true

        // Remove bubble after animation completes (0.35s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.bubbles.removeAll { $0.id == bubble.id }
        }

        // Remove score popup after it floats away (0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.scorePopups.removeAll { $0.id == bubble.id }
        }
    }
    
    // MARK: - End game
    private func endGame() {
        timer?.cancel()
        timer = nil
        isGameRunning = false
        isGameOver = true
        bubbles = []
        
        // Save score to persistence
        scoreService.saveScore(playerName: playerName, score: score)
    }
    
    // MARK: - Restart game
    func restartGame() {
        isGameOver = false
        isGameRunning = false
        score = 0
        timeLeft = 0
        bubbles = []
        lastPoppedColor = nil
    }
}
