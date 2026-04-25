//
//  BubbleGenerator.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

struct BubbleGenerator {
    
    // MARK: - Pick a random colour based on probability
    static func randomBubbleColor() -> BubbleColor {
        let random = Double.random(in: 0..<1)
        var cumulative = 0.0
        
        for color in BubbleColor.allCases {
            cumulative += color.probability
            if random < cumulative {
                return color
            }
        }
        return .red // fallback, should never reach here
    }
    
    // MARK: - Generate a valid random position
    static func randomPosition(
        existingBubbles: [Bubble],
        screenSize: CGSize,
        radius: CGFloat
    ) -> CGPoint? {
        
        let maxAttempts = 50
        let padding: CGFloat = radius + 10
        
        for _ in 0..<maxAttempts {
            // Pick a random point within screen bounds
            let x = CGFloat.random(in: padding...(screenSize.width - padding))
            let y = CGFloat.random(in: padding...(screenSize.height - padding))
            let candidate = CGPoint(x: x, y: y)
            
            // Check it doesn't overlap any existing bubble
            let overlaps = existingBubbles.contains { bubble in
                let dx = bubble.position.x - candidate.x
                let dy = bubble.position.y - candidate.y
                let distance = sqrt(dx*dx + dy*dy)
                return distance < (bubble.radius + radius + 5)
            }
            
            if !overlaps {
                return candidate
            }
        }
        
        // Could not find valid position after maxAttempts
        return nil
    }
    
    // MARK: - Generate a full set of bubbles
    static func generateBubbles(
        count: Int,
        existingBubbles: [Bubble],
        screenSize: CGSize
    ) -> [Bubble] {
        var newBubbles: [Bubble] = []
        
        for _ in 0..<count {
            let allBubbles = existingBubbles + newBubbles
            if let position = randomPosition(
                existingBubbles: allBubbles,
                screenSize: screenSize,
                radius: 30
            ) {
                let bubble = Bubble(
                    bubbleColor: randomBubbleColor(),
                    position: position
                )
                newBubbles.append(bubble)
            }
        }
        return newBubbles
    }
}
