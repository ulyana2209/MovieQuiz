//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by user on 18.04.2026.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
     
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testGameFinish() {
        sleep(5)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        let alert = app.alerts["Раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
          
        XCTAssertEqual(alert.label, "Раунд окончен!")
        XCTAssertEqual(alert.buttons["Сыграть ещё раз"].label, "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        let alert = app.alerts["Раунд окончен!"]
        alert.buttons.firstMatch.tap()
        XCTAssertFalse(alert.exists)
        sleep(2)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
        
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(2)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
        
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
}

