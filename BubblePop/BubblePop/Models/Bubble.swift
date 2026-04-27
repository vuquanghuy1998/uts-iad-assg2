//
//  Bubble.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

struct Bubble: Identifiable {
    let id = UUID()
    let bubbleColor: BubbleColor
    var position: CGPoint
    let radius: CGFloat = 30
    var isPopped: Bool = false
    var velocity: CGVector = .zero  // points per second

    // Convenience passthroughs from BubbleColor
    var points: Int { bubbleColor.points }
    var color: Color { bubbleColor.color }
}
