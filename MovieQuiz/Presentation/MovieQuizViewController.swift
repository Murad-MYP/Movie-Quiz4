    import UIKit

    final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
        
        // MARK: - Properties
        private let questionsAmount: Int = 10
        private var questionFactory: QuestionFactoryProtocol?
        private var alertPresnter: AlertPresenter?
        private var currentQuestion: QuizQuestion?
        private var currentQuestionIndex = 0
        private var correctAnswers = 0
        private var isAlertPresented = false
        private var statisticService: StatisticServiceProtocol = StatisticService()

        // MARK: - UI Elements
        @IBOutlet private var yesButton: UIButton!
        @IBOutlet private var noButton: UIButton!
        @IBOutlet private var questionLabel: UILabel!
        @IBOutlet private var counterLabel: UILabel!
        @IBOutlet private var textLabel: UILabel!
        @IBOutlet private var imageView: UIImageView!

        // MARK: - Lifecycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
            statisticService = StatisticService()
            imageView.layer.cornerRadius = 20
            let questionFactory = QuestionFactory()
            questionFactory.delegate = self
            self.questionFactory = questionFactory
            
            let alertPresenter = AlertPresenter(viewController: self)
            self.alertPresnter = alertPresenter
            
            questionFactory.requestNextQuestion()
            
            
    }

        // MARK: - QuestionFactoryDelegate
        
        func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question  else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            
            DispatchQueue.main.async { [weak self] in
                self?.show(quiz: viewModel)
            }
        }
        
        // MARK: - Quiz Logic
        private func checkAnswer(_ userAnswer: Bool) -> Bool {
            guard let currentQuestion = currentQuestion else {
                return false
            }
            return currentQuestion.correctAnswer == userAnswer
        }

        private func showAnswerResult(isCorrect: Bool) {
            // Disable the buttons after an answer is selected
            changeStatusButton(isEnabled: false)

            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
            
            if isCorrect {
                correctAnswers += 1
            }

            // Показать следующий вопрос через 1 секунду
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showNextQuestionOrResult()
            }
        }

        private func showNextQuestionOrResult() {
            // Убираем рамку вокруг изображения
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = UIColor.clear.cgColor
            
            // Проверяем, закончились ли вопросы
            if currentQuestionIndex == questionsAmount - 1 {
                showResults()
            } else {
                // Увеличиваем индекс текущего вопроса
                currentQuestionIndex += 1
                // Показываем следующий вопрос
                questionFactory?.requestNextQuestion()
                // Разблокируем кнопки для следующего вопроса
                changeStatusButton(isEnabled: true) // Enable buttons for the next question
            }
        }
        
        private func convert(model: QuizQuestion) -> QuizStepViewModel {
            return QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
            )
        }

      
        private func changeStatusButton(isEnabled: Bool) {
            noButton.isEnabled = isEnabled
            yesButton.isEnabled = isEnabled
        }

        private func resetGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
            changeStatusButton(isEnabled: true)
        }

        private func showResults() {
            if isAlertPresented { return }
            
            isAlertPresented = true
            
            let bestGame = statisticService.bestGame
            let gamesCount = statisticService.gamesCount
            let accuracy = statisticService.totalAccuracy
            
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm"
            let formattedDate = dateFormatter.string(from: bestGame.date)
            
            let message = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(formattedDate)
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
            
            // Используем AlertPresenter для показа алерта
            let alertModel = AlertModel(
                title: "Этот раунд окончен! ",
                message: message,
                buttonText: "Сыграть ещё раз") { [weak self] in
                    guard let self = self else { return }
                    self.isAlertPresented = false
                    self.resetGame()
                }
            
            alertPresnter?.showAlert(model: alertModel) // Показываем алерт через AlertPresenter
        }
        
        private func show(quiz step: QuizStepViewModel) {
            imageView.image = step.image
            textLabel.text = step.question
            counterLabel.text = step.questionNumber
        }

        // MARK: - Button Actions
        @IBAction private func noButtonClicked(_ sender: UIButton) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            let givenAnswer = false
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }

        @IBAction private func yesButtonClicked(_ sender: UIButton) {
            guard let currentQuestion = currentQuestion else {
                return
            } 
            let givenAnswer = true
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    }

