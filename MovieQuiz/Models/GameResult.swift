//
//  GameResult.swift
//  MovieQuiz
//
//  Created by user on 25.03.2026.
//
import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func compare(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}

