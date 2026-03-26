//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by user on 20.03.2026.
//

protocol QuestionFactoryProtocol {
    func requestNextQuestion() 
    func resetQuestions()
    func getTotalQuestionsCount() -> Int
}
