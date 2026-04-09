//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by user on 19.03.2026.
//
import Foundation
import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    
    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    //    var currentQuestions: [QuizQuestion] = []
    //
    //    private let questions: [QuizQuestion] = [
    //        QuizQuestion(
    //            image: "The Godfather",
    //            text: "Рейтинг этого фильма больше чем 5?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "The Dark Knight",
    //            text: "Рейтинг этого фильма больше чем 5?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image:"Kill Bill",
    //            text: "Рейтинг этого фильма больше чем 5?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "The Avengers",
    //            text: "Рейтинг этого фильма больше чем 5?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "Deadpool",
    //            text: "Рейтинг этого фильма больше чем 5?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "The Green Knight",
    //            text: "Рейтинг этого фильма больше чем 5?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "Old",
    //            text: "Рейтинг этого фильма больше чем 5?",
    //            correctAnswer: false),
    //        QuizQuestion(
    //            image: "The Ice Age Adventures of Buck Wild",
    //            text: "Рейтинг этого фильма больше чем 5?",
    //            correctAnswer: false),
    //        QuizQuestion(
    //            image: "Tesla",
    //            text: "Рейтинг этого фильма больше чем 5?",
    //            correctAnswer: false),
    //        QuizQuestion(
    //            image: "Vivarium",
    //            text: "Рейтинг этого фильма больше чем 5?",
    //            correctAnswer: false)
    //    ]
    
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    private func configureQuizQuestion() {
        
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self]  in
            guard let self = self else { return }
            let index = (0..<movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Ошибка загрузки картинки")
            }
            
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            movies.remove(at: index)
            DispatchQueue.main.async { [ weak self]  in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func getTotalQuestionsCount() -> Int {
        movies.count
    }
}
