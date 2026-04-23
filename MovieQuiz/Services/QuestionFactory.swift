//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by user on 19.03.2026.
//
import Foundation
import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    // MARK: - Private Properties
    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    // MARK: - Init
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    // MARK: - Methods
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
                delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func getTotalQuestionsCount() -> Int {
        movies.count
    }
}
