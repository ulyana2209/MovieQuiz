//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by user on 22.03.2026.
//

import UIKit
final class AlertPresenter {
    
  weak var viewController: UIViewController?
    
    func showAlert(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
}
