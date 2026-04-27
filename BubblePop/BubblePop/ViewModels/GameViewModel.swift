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
    private var displayLink: CADisplayLink?
    private var lastFrameTime: CFTimeInterval = 0
    private var lastPoppedColor: BubbleColor? = nil
    private var screenSize: CGSize = .zero
    private let settings = GameSettings.shared
    private let scoreService = ScoreService.shared
    private var totalGameTime: Int = 60

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
        self.totalGameTime = settings.gameTime
        self.bubbles = []
        self.isGameOver = false
        self.isGameRunning = true
        self.lastPoppedColor = nil

        spawnBubbles()
        startDisplayLink()

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
        let live = bubbles.filter { !$0.isPopped }
        let removeCount = Int.random(in: 0...max(0, live.count))
        bubbles = Array(live.shuffled().dropFirst(removeCount))
        spawnBubbles()
    }

    // MARK: - Spawn new bubbles
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

    // MARK: - Display link (~60 fps movement)
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
        guard lastFrameTime > 0 else {
            lastFrameTime = link.timestamp
            return
        }
        let dt = CGFloat(link.timestamp - lastFrameTime)
        lastFrameTime = link.timestamp

        // Speed grows from 1× at game start to 3× at game end
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

            // Bounce off the TOP edge — prevents bubbles drifting over the header
            if p.y - r < 0 {
                bubbles[i].position.y = r
                bubbles[i].velocity.dy = abs(bubbles[i].velocity.dy)  // flip downward
            }

            // Remove when fully off left, right, or bottom edges (per EF1 spec)
            if p.x + r < 0
                || p.x - r > screenSize.width
                || p.y - r > screenSize.height {
                toRemove.append(bubbles[i].id)
            }
        }

        if !toRemove.isEmpty {
            bubbles.removeAll { toRemove.contains($0.id) }
        }
    }

    // MARK: - Pop a bubble
    func popBubble(_ bubble: Bubble) {
        guard let index = bubbles.firstIndex(where: { $0.id == bubble.id }),
              !bubbles[index].isPopped
        else { return }

        var pointsEarned = bubble.points
        let isCombo = lastPoppedColor == bubble.bubbleColor
        if isCombo {
            pointsEarned = Int((Double(bubble.points) * 1.5).rounded())
        }
        score += pointsEarned
        lastPoppedColor = bubble.bubbleColor

        let popup = ScorePopup(
            id: bubble.id,
            points: pointsEarned,
            isCombo: isCombo,
            position: bubble.position
        )
        scorePopups.append(popup)

        bubbles[index].isPopped = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.bubbles.removeAll { $0.id == bubble.id }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.scorePopups.removeAll { $0.id == bubble.id }
        }
    }

    // MARK: - End game
    private func endGame() {
        timer?.cancel()
        timer = nil
        stopDisplayLink()
        isGameRunning = false
        isGameOver = true
        bubbles = []
        scoreService.saveScore(playerName: playerName, score: score)
    }

    // MARK: - Restart game
    func restartGame() {
        stopDisplayLink()
        isGameOver = false
        isGameRunning = false
        score = 0
        timeLeft = 0
        bubbles = []
        lastPoppedColor = nil
    }
}
