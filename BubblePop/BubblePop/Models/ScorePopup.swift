//
//  ScorePopup.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 27/4/2026.
//

import Foundation
 
/// Represents a floating "+N" label shown when a bubble is popped.
struct ScorePopup: Identifiable {
    let id: UUID          // matches the bubble's id so we can remove together
    let points: Int
    let isCombo: Bool
    let position: CGPoint
}
