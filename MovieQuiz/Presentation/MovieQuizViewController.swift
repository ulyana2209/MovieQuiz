import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - Private Properties
    
    private var questionsAmount: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    weak var delegate: QuestionFactoryDelegate?
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()

    // MARK: - Overrides Methods
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
        setupUI()
        setupDependencies()
    }
    
    // MARK: - Setup
    
    private func setupDependencies() {
        let moviesLoader = MoviesLoader()
        let factory = QuestionFactory(delegate: self, moviesLoader: moviesLoader)
        alertPresenter.viewController = self
        questionsAmount = 10
        questionFactory = factory
        questionFactory?.loadData()
      }
    
    private func setupUI() {
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }
    
    private func loadFirstQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        } 
        let givenAnswer = false
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image)
        return QuizStepViewModel(image: image ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/10")
    }
    
    
   
    private func show(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        print(step.image.size)
    
    }
    
   
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            imageView.layer.cornerRadius = 20
            correctAnswers += 1
        } else {
            if isCorrect == false {
                imageView.layer.masksToBounds = true
                imageView.layer.borderWidth = 8
                imageView.layer.borderColor = UIColor.ypRed.cgColor
                imageView.layer.cornerRadius = 20
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }


    private func showNextQuestionOrResults() {
        currentQuestionIndex += 1
        if currentQuestionIndex < 10 {
            questionFactory?.requestNextQuestion()
        } else {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            print("total acuracy: \(statisticService.totalAccuracy)")
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/10\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/10 (\(bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                buttonText: "Сыграть еще раз"
            )

            
            let model = AlertModel(
                title: viewModel.title,
                message: viewModel.text,
                buttonText: viewModel.buttonText
            ) {
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.loadData()
                self.questionFactory?.requestNextQuestion()
            }
            
            alertPresenter.showAlert(model: model)
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.showAlert(model: model)
    }
    
    //MARK: Delegate Method
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        show(quiz: viewModel)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
