import Foundation
import Observation

@Observable
@MainActor
final class HistoryViewModel {
    var entries: [DailyEntry] = []
    var selectedEntry: DailyEntry?
    var factors: [EmotionalFactor] = []
    var isLoading = false
    var errorMessage: String?
    
    init() {
        // Data loading deferred to onAppear in the view
    }
    
    func loadData() {
        isLoading = true
        
        do {
            self.entries = try DataRepository.shared.getAllEntries()
            self.factors = try DataRepository.shared.getActiveFactors()
            self.isLoading = false
        } catch {
            self.errorMessage = "Error al cargar historial: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func selectEntry(_ entry: DailyEntry) {
        selectedEntry = entry
    }
    
    func deleteEntry(_ entry: DailyEntry) {
        do {
            try DataRepository.shared.deleteEntry(entry)
            entries.removeAll { $0.id == entry.id }
        } catch {
            self.errorMessage = "Error al eliminar: \(error.localizedDescription)"
        }
    }
    
    func getFactorName(for factorId: UUID) -> String {
        factors.first(where: { $0.id == factorId })?.name ?? "Desconocido"
    }
    
    func updateEntryScore(_ score: Int, for factorId: UUID, in entry: DailyEntry) {
        entry.setScore(score, for: factorId)
        
        do {
            try DataRepository.shared.updateEntry(entry)
        } catch {
            self.errorMessage = "Error al actualizar: \(error.localizedDescription)"
        }
    }
}
