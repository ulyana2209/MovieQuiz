//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by user on 21.03.2026.
//
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() 
    func didFailToLoadData(with error: Error)
}
