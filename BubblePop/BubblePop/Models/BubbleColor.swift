//
//  BubbleColor.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

enum BubbleColor: CaseIterable {
    case red, pink, green, blue, black
    
    // Points each colour is worth
    var points: Int {
        switch self {
        case .red:   return 1
        case .pink:  return 2
        case .green: return 5
        case .blue:  return 8
        case .black: return 10
        }
    }
    
    // Probability of appearance (must sum to 1.0)
    var probability: Double {
        switch self {
        case .red:   return 0.40
        case .pink:  return 0.30
        case .green: return 0.15
        case .blue:  return 0.10
        case .black: return 0.05
        }
    }
    
    // The actual SwiftUI colour to display
    var color: Color {
        switch self {
        case .red:   return .red
        case .pink:  return Color(.systemPink)
        case .green: return .green
        case .blue:  return .blue
        case .black: return .black
        }
    }
}
