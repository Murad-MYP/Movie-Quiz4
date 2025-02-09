import Foundation

final class StatisticService {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        public enum BestGame: String {
            case date
            case correct
            case total
        }
        case correctAnswers
        case gamesCount
    }
}
    extension StatisticService: StatisticServiceProtocol {
        var gamesCount: Int {
            get {
                return storage.integer(forKey: Keys.gamesCount.rawValue)
            }
            set {
                storage.set(newValue, forKey: Keys.gamesCount.rawValue)
            }
        }
    // correctAnswers
        var correctAnswers: Int {
            get {
                return storage.integer(forKey: Keys.correctAnswers.rawValue)
            }
            set {
                storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
            }
        }
    // bestGame
        var bestGame: GameResult {
            get {
                let correct = storage.integer(forKey:Keys.BestGame.correct.rawValue)
                let total = storage.integer(forKey: Keys.BestGame.total.rawValue)
                let date = storage.object(forKey: Keys.BestGame.date.rawValue) as? Date ?? Date()
                
                return GameResult(correct: correct, total: total, date: date)
            }
            
            set {
                storage.set(newValue.correct, forKey: Keys.BestGame.correct.rawValue )
                storage.set(newValue.total, forKey:Keys.BestGame.total.rawValue)
                storage.set(newValue.date, forKey: Keys.BestGame.date.rawValue)
            }
        }

// Средняя точность ответов
    var totalAccuracy: Double {
        get {
            let  correctAnswers = self.correctAnswers
            let totalQuestions = gamesCount * 10
            return totalQuestions != 0 ? 100 * Double(correctAnswers)/Double(totalQuestions): 0
        }
    }
    
        func store(correct count: Int, total amount: Int) {
            // Обновляем количество сыгранных игр
            gamesCount += 1
            //  Обновляем количество правильных ответов
            correctAnswers += count
            
            //  Проверяем, если текущий результат лучше, чем рекорд
            let currentGameResult = GameResult(correct: count, total: amount, date: Date())
            if currentGameResult.isBetterThan(bestGame) {
                bestGame = currentGameResult
            }
            
        }
}
