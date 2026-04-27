//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by user on 21.04.2026.
//
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    private let statisticService: StatisticServiceProtocol
    private let alertPresenter = AlertPresenter()
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    
    // MARK: - Init
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.statisticService = StatisticService()
        self.questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        viewController.showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter.viewController = viewController as? UIViewController
    }
    // MARK: - Public Methods
    func makeResultsMessage() -> String {
        statisticService.store(correct:
                                correctAnswers, total: questionsAmount)
        
        print("total acuracy: \(statisticService.totalAccuracy)")
        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let totalPlaysCountLine = "Количество сыгранных квизов: \(gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)" + " \(bestGame.date.dateTimeString)"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let result = makeResultsMessage()
            let model = AlertModel(title: "Раунд окончен!", message: result, buttonText: "Сыграть ещё раз") {
                self.restartGame()
            }
            alertPresenter.showAlert(model: model)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
    }
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
}
