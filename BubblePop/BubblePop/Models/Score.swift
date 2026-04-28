//
//  Score.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import Foundation

struct Score: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let playerName: String
    let score: Int
}
