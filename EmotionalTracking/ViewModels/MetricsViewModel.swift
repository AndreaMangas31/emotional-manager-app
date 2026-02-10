import Foundation
import Observation

@Observable
@MainActor
final class MetricsViewModel {
    var factors: [EmotionalFactor] = []
    var entries: [DailyEntry] = []
    var isLoading = false
    var errorMessage: String?
    
    var lastSevenDaysEntries: [DailyEntry] = []
    var lastThirtyDaysEntries: [DailyEntry] = []
    
    init() {
        // Data loading deferred to onAppear in the view
    }
    
    func loadData() {
        isLoading = true
        
        do {
            self.factors = try DataRepository.shared.getActiveFactors()
            let allEntries = try DataRepository.shared.getAllEntries()
            self.entries = allEntries
            
            let now = Date()
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
            
            self.lastSevenDaysEntries = try DataRepository.shared.getEntriesForDateRange(sevenDaysAgo, now)
            self.lastThirtyDaysEntries = try DataRepository.shared.getEntriesForDateRange(thirtyDaysAgo, now)
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Error al cargar métricas: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    // MARK: - Calculation Methods
    
    func getOverallAverage(for period: [DailyEntry]) -> Double {
        guard !period.isEmpty else { return 0 }
        let sum = period.reduce(0) { $0 + $1.averageScore }
        return sum / Double(period.count)
    }
    
    func getFactorAverage(for factorId: UUID, in period: [DailyEntry]) -> Double {
        let scores = period.compactMap { $0.getScore(for: factorId) }
        guard !scores.isEmpty else { return 0 }
        return Double(scores.reduce(0, +)) / Double(scores.count)
    }
    
    func getTrendData(for factorId: UUID) -> [(Date, Int)] {
        return lastThirtyDaysEntries
            .compactMap { entry in
                if let score = entry.getScore(for: factorId) {
                    return (entry.date, score)
                }
                return nil
            }
            .sorted { $0.0 < $1.0 }
    }
    
    func getCountDataPoints(for factorId: UUID) -> Int {
        return lastThirtyDaysEntries.filter { $0.getScore(for: factorId) != nil }.count
    }
    
    // MARK: - Statistics
    
    func getStatistics(for factorId: UUID) -> FactorStatistics {
        let sevenDaysAvg = getFactorAverage(for: factorId, in: lastSevenDaysEntries)
        let thirtyDaysAvg = getFactorAverage(for: factorId, in: lastThirtyDaysEntries)
        
        return FactorStatistics(
            sevenDaysAverage: sevenDaysAvg,
            thirtyDaysAverage: thirtyDaysAvg,
            highestScore: entries.compactMap { $0.getScore(for: factorId) }.max() ?? 0,
            lowestScore: entries.compactMap { $0.getScore(for: factorId) }.min() ?? 0
        )
    }
}

struct FactorStatistics {
    let sevenDaysAverage: Double
    let thirtyDaysAverage: Double
    let highestScore: Int
    let lowestScore: Int
}
