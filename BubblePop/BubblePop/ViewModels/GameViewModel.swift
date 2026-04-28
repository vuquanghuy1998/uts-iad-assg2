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
    /// Toggles every time the score increases — used to drive a header flash animation
    @Published var scoreDidChange: Bool = false
    /// Current consecutive combo length (resets to 1 when colour changes)
    @Published var comboCount: Int = 0
    /// Highest score across all players — published so the header stays reactive
    @Published var highestScore: Int = 0

    // MARK: - Private state
    private var timer: AnyCancellable?
    private var displayLink: CADisplayLink?
    private var lastFrameTime: CFTimeInterval = 0
    private var lastPoppedColor: BubbleColor? = nil
    private var screenSize: CGSize = .zero
    private let settings = GameSettings.shared
    private let scoreService = ScoreService.shared
    private var totalGameTime: Int = 60

    // MARK: - Player info
    var playerName: String = ""

    // MARK: - Start game
    func startGame(screenSize: CGSize) {
        self.screenSize = screenSize
        self.score = 0
        self.timeLeft = settings.gameTime
        self.totalGameTime = settings.gameTime
        self.bubbles = []
        self.isGameOver = false
        self.isGameRunning = true
        self.lastPoppedColor = nil
        self.comboCount = 0
        self.highestScore = scoreService.highestScore()

        spawnBubbles()
        startDisplayLink()

        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.onTick() }
    }

    // MARK: - Per-second tick
    private func onTick() {
        guard timeLeft > 0 else { endGame(); return }
        timeLeft -= 1
        refreshBubbles()
        if timeLeft == 0 { endGame() }
    }

    // MARK: - Refresh the bubble field every second (CF9)
    private func refreshBubbles() {
        let live = bubbles.filter { !$0.isPopped }
        let removeCount = Int.random(in: 0...max(0, live.count))
        bubbles = Array(live.shuffled().dropFirst(removeCount))
        spawnBubbles()
    }

    // MARK: - Spawn new bubbles up to maxBubbles (CF5, CF6)
    private func spawnBubbles() {
        let maxBubbles = settings.maxBubbles
        let currentCount = bubbles.filter { !$0.isPopped }.count
        guard currentCount < maxBubbles else { return }
        let spotsAvailable = maxBubbles - currentCount
        let newCount = Int.random(in: 0...spotsAvailable)
        let newBubbles = BubbleGenerator.generateBubbles(
            count: newCount,
            existingBubbles: bubbles,
            screenSize: screenSize
        )
        bubbles.append(contentsOf: newBubbles)
    }

    // MARK: - CADisplayLink for smooth movement (EF1)
    private func startDisplayLink() {
        stopDisplayLink()
        lastFrameTime = 0
        let dl = CADisplayLink(target: self, selector: #selector(onFrame))
        dl.add(to: .main, forMode: .common)
        displayLink = dl
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func onFrame(_ link: CADisplayLink) {
        guard lastFrameTime > 0 else { lastFrameTime = link.timestamp; return }
        let dt = CGFloat(link.timestamp - lastFrameTime)
        lastFrameTime = link.timestamp

        // Speed increases from 1× at the start to 3× at the end (EF1)
        let progress = totalGameTime > 0
            ? CGFloat(totalGameTime - timeLeft) / CGFloat(totalGameTime)
            : 1.0
        let speedMultiplier: CGFloat = 1.0 + progress * 2.0

        var toRemove: [UUID] = []

        for i in bubbles.indices {
            guard !bubbles[i].isPopped else { continue }

            bubbles[i].position.x += bubbles[i].velocity.dx * speedMultiplier * dt
            bubbles[i].position.y += bubbles[i].velocity.dy * speedMultiplier * dt

            let r = bubbles[i].radius
            let p = bubbles[i].position

            // Bounce off the top edge so bubbles stay in the game area
            if p.y - r < 0 {
                bubbles[i].position.y = r
                bubbles[i].velocity.dy = abs(bubbles[i].velocity.dy)
            }

            // Exit off left, right, or bottom (EF1 — "go off the screen")
            if p.x + r < 0 || p.x - r > screenSize.width || p.y - r > screenSize.height {
                toRemove.append(bubbles[i].id)
            }
        }

        if !toRemove.isEmpty {
            bubbles.removeAll { toRemove.contains($0.id) }
        }
    }

    // MARK: - Pop a bubble (CF8)
    func popBubble(_ bubble: Bubble) {
        guard let index = bubbles.firstIndex(where: { $0.id == bubble.id }),
              !bubbles[index].isPopped
        else { return }

        // Combo multiplier: 1.5× for consecutive same-colour pops (CF8)
        let isCombo = lastPoppedColor == bubble.bubbleColor
        comboCount = isCombo ? comboCount + 1 : 1
        lastPoppedColor = bubble.bubbleColor

        let pointsEarned = isCombo
            ? Int((Double(bubble.points) * 1.5).rounded())
            : bubble.points
        score += pointsEarned
        scoreDidChange.toggle()    // triggers header flash (EF2c)

        scorePopups.append(ScorePopup(
            id: bubble.id,
            points: pointsEarned,
            isCombo: isCombo,
            position: bubble.position
        ))

        bubbles[index].isPopped = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.bubbles.removeAll { $0.id == bubble.id }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.scorePopups.removeAll { $0.id == bubble.id }
        }
    }

    // MARK: - End game (CF10)
    private func endGame() {
        timer?.cancel()
        timer = nil
        stopDisplayLink()
        isGameRunning = false
        isGameOver = true
        bubbles = []
        scoreService.saveScore(playerName: playerName, score: score)
    }

    // MARK: - Reset to pre-game idle state (called before a new countdown)
    func restartGame() {
        stopDisplayLink()
        isGameOver = false
        isGameRunning = false
        score = 0
        timeLeft = 0
        bubbles = []
        lastPoppedColor = nil
        comboCount = 0
        highestScore = scoreService.highestScore()
    }
}
