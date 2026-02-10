import Foundation
import SwiftData

@Model
final class DailyEntry: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var date: Date
    var factorScores: [UUID: Int] = [:]  // Factor ID -> Score (1-10)
    var notes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init(date: Date = Date()) {
        self.date = date.startOfDay
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Obtiene el score para un factor específico
    func getScore(for factorId: UUID) -> Int? {
        return factorScores[factorId]
    }
    
    /// Establece el score para un factor
    func setScore(_ score: Int, for factorId: UUID) {
        factorScores[factorId] = max(1, min(10, score))
        updatedAt = Date()
    }
    
    /// Calcula la media de todos los scores del día
    var averageScore: Double {
        guard !factorScores.isEmpty else { return 0 }
        let sum = factorScores.values.reduce(0, +)
        return Double(sum) / Double(factorScores.count)
    }
    
    /// Verifica si el registro del día está completo
    func isComplete(expectedFactorCount: Int) -> Bool {
        return factorScores.count == expectedFactorCount && !factorScores.values.contains(0)
    }
}

// MARK: - Date Extensions
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: self)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
