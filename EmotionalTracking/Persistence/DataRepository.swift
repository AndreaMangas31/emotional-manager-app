import Foundation
import SwiftData

@MainActor
class DataRepository {
    static let shared = DataRepository()
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        initializeDefaultFactorsIfNeeded()
    }
    
    func setupModelContainer() throws -> ModelContainer {
        let schema = Schema([
            EmotionalFactor.self,
            DailyEntry.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelContext = ModelContext(container)
        return container
    }
    
    // MARK: - EmotionalFactor Operations
    
    func getAllFactors() throws -> [EmotionalFactor] {
        guard let context = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<EmotionalFactor>()
        descriptor.sortBy = [SortDescriptor(\.order)]
        
        return try context.fetch(descriptor)
    }
    
    func getActiveFactors() throws -> [EmotionalFactor] {
        guard let context = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<EmotionalFactor>(
            predicate: #Predicate { $0.isActive }
        )
        descriptor.sortBy = [SortDescriptor(\.order)]
        
        return try context.fetch(descriptor)
    }
    
    func addFactor(_ factor: EmotionalFactor) throws {
        guard let context = modelContext else { return }
        context.insert(factor)
        try context.save()
    }
    
    func updateFactor(_ factor: EmotionalFactor) throws {
        guard let context = modelContext else { return }
        try context.save()
    }
    
    func deleteFactor(_ factor: EmotionalFactor) throws {
        guard let context = modelContext else { return }
        context.delete(factor)
        try context.save()
    }
    
    // MARK: - DailyEntry Operations
    
    func getTodayEntry() throws -> DailyEntry? {
        guard let context = modelContext else { return nil }
        
        let today = Date().startOfDay
        var descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { entry in
                entry.date == today
            }
        )
        descriptor.fetchLimit = 1
        
        return try context.fetch(descriptor).first
    }
    
    func getOrCreateTodayEntry() throws -> DailyEntry {
        if let existing = try getTodayEntry() {
            return existing
        }
        
        let newEntry = DailyEntry(date: Date())
        guard let context = modelContext else { return newEntry }
        context.insert(newEntry)
        try context.save()
        return newEntry
    }
    
    func getEntryForDate(_ date: Date) throws -> DailyEntry? {
        guard let context = modelContext else { return nil }
        
        let targetDate = date.startOfDay
        var descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { entry in
                entry.date == targetDate
            }
        )
        descriptor.fetchLimit = 1
        
        return try context.fetch(descriptor).first
    }
    
    func getAllEntries() throws -> [DailyEntry] {
        guard let context = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<DailyEntry>()
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        
        return try context.fetch(descriptor)
    }
    
    func getEntriesForDateRange(_ start: Date, _ end: Date) throws -> [DailyEntry] {
        guard let context = modelContext else { return [] }
        
        let startDate = start.startOfDay
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: end.startOfDay) ?? end
        
        var descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { entry in
                entry.date >= startDate && entry.date < endDate
            }
        )
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        
        return try context.fetch(descriptor)
    }
    
    func saveEntry(_ entry: DailyEntry) throws {
        guard let context = modelContext else { return }
        context.insert(entry)
        try context.save()
    }
    
    func updateEntry(_ entry: DailyEntry) throws {
        guard let context = modelContext else { return }
        try context.save()
    }
    
    func deleteEntry(_ entry: DailyEntry) throws {
        guard let context = modelContext else { return }
        context.delete(entry)
        try context.save()
    }
    
    // MARK: - Initialization
    
    private func initializeDefaultFactorsIfNeeded() {
        guard let context = modelContext else { return }
        
        do {
            let existing = try getAllFactors()
            
            // Si no hay factores, crear los default
            if existing.isEmpty {
                for defaultFactor in EmotionalFactor.defaultFactors {
                    context.insert(defaultFactor)
                }
                try context.save()
            }
        } catch {
            print("Error initializing default factors: \(error)")
        }
    }
}
