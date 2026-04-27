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

    // Convenience passthroughs from BubbleColor
    var points: Int { bubbleColor.points }
    var color: Color { bubbleColor.color }
}
