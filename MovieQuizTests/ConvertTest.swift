//
//  ConvertTest.swift
//  MovieQuiz
//
//  Created by user on 22.04.2026.
//
import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
       var lastStepModel: QuizStepViewModel?
       var lastResultModel: QuizResultsViewModel?
       var didShowLoading = false
       var didHideLoading = false
       var lastErrorMessage: String?
       var lastHighlightState: Bool?
    

    func show(quiz step: QuizStepViewModel) {
    lastStepModel = step
    }
    
    func highlightImageBorder(isCorrect: Bool) {
    lastHighlightState = isCorrect
    }
    
    func showLoadingIndicator() {
        didShowLoading = true
    }
    
    func hideLoadingIndicator() {
        didHideLoading = true
    }
    
    func showNetworkError(message: String) {
        lastErrorMessage = message
    }
}
final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertEqual(viewControllerMock.lastStepModel?.image, UIImage(data: emptyData))
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
