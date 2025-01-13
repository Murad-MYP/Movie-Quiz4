import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - ViewModel Structures
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    struct ResponseResultViewModel {
        let result: Bool
    }
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    // MARK: - Properties
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isAlertPresented = false

    // MARK: - UI Elements
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        showCurrent() // Отображаем первый вопрос
    }

    // MARK: - Quiz Logic
    private func checkAnswer(_ userAnswer: Bool) -> Bool {
        let currentQuestion = questions[currentQuestionIndex]
        return currentQuestion.correctAnswer == userAnswer
    }

    private func showAnswerResult(isCorrect: Bool) {
        // Disable the buttons after an answer is selected
        changeStatusButton(isEnabled: false)

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.green.cgColor : UIColor.red.cgColor
        
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
        if currentQuestionIndex == questions.count - 1 {
            showResults()
        } else {
            // Увеличиваем индекс текущего вопроса
            currentQuestionIndex += 1
            // Показываем следующий вопрос
            let nextQuestion = convert(model: questions[currentQuestionIndex])
            show(quiz: nextQuestion)
            showCurrent()
            // Разблокируем кнопки для следующего вопроса
            changeStatusButton(isEnabled: true) // Enable buttons for the next question
        }
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }

    private func showCurrent() {
        let currentQuestion = questions[currentQuestionIndex]
        let currentView = convert(model: currentQuestion)
        show(quiz: currentView)
    }

    private func changeStatusButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }

    private func resetGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showCurrent()
        changeStatusButton(isEnabled: true)
    }

    private func showResults() {
        if isAlertPresented { return }

        isAlertPresented = true
        let alert = UIAlertController(
            title: "Раунд окончен!",
            message: "Вы ответили правильно на \(correctAnswers) из \(questions.count) вопросов.",
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: "Сыграть ещё раз", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.isAlertPresented = false
            self.resetGame()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    // MARK: - Button Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
//      4 Спринт
