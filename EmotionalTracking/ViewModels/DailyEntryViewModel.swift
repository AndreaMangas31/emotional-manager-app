import Foundation
import Observation

@Observable
@MainActor
final class DailyEntryViewModel {
    var todayEntry: DailyEntry?
    var factors: [EmotionalFactor] = []
    var isLoading = false
    var errorMessage: String?
    
    init() {
        // Data loading deferred to onAppear in the view
    }
    
    func loadTodayEntry() {
        isLoading = true
        
        do {
            // Cargar factores activos
            self.factors = try DataRepository.shared.getActiveFactors()
            
            // Cargar o crear entrada de hoy
            self.todayEntry = try DataRepository.shared.getOrCreateTodayEntry()
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Error al cargar datos: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func updateScore(_ score: Int, for factorId: UUID) {
        todayEntry?.setScore(score, for: factorId)
        
        do {
            if let entry = todayEntry {
                try DataRepository.shared.updateEntry(entry)
            }
        } catch {
            self.errorMessage = "Error al guardar: \(error.localizedDescription)"
        }
    }
    
    func setNotes(_ notes: String) {
        todayEntry?.notes = notes
        
        do {
            if let entry = todayEntry {
                try DataRepository.shared.updateEntry(entry)
            }
        } catch {
            self.errorMessage = "Error al guardar notas: \(error.localizedDescription)"
        }
    }
    
    func getScore(for factorId: UUID) -> Int {
        return todayEntry?.getScore(for: factorId) ?? 0
    }
    
    func isTodayEntryComplete() -> Bool {
        return todayEntry?.isComplete(expectedFactorCount: factors.count) ?? false
    }
}
