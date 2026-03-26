//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by user on 19.03.2026.
//
import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    
    init() {
        self.currentQuestions = questions
    }
    
    var currentQuestions: [QuizQuestion] = []
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: true),
        QuizQuestion(
            image:"Kill Bill",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: false)
    ]
    
    func requestNextQuestion() {
        guard let index = (0..<currentQuestions.count).randomElement() else {
           delegate?.didReceiveNextQuestion(question: nil)
           return
        }
        let question = currentQuestions[safe: index]
        currentQuestions.remove(at: index)
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    func resetQuestions() {
        currentQuestions = questions
    }
    
    func getTotalQuestionsCount() -> Int {
        questions.count
    }
    
}
