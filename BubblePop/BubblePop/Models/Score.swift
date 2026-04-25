//
//  Score.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import Foundation

struct Score: Codable, Identifiable {
    let id = UUID()
    let playerName: String
    let score: Int
}
