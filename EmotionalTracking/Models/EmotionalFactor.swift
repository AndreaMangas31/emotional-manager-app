import Foundation
import SwiftData

@Model
final class EmotionalFactor: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var order: Int
    var isCustom: Bool = false
    var isActive: Bool = true
    var createdAt: Date = Date()
    
    init(name: String, order: Int, isCustom: Bool = false) {
        self.name = name
        self.order = order
        self.isCustom = isCustom
    }
}

// Factores predeterminados
extension EmotionalFactor {
    static let defaultFactors: [EmotionalFactor] = [
        EmotionalFactor(name: "Soledad", order: 0),
        EmotionalFactor(name: "Inseguridad / Miedo", order: 1),
        EmotionalFactor(name: "Familia", order: 2),
        EmotionalFactor(name: "Amistades", order: 3),
        EmotionalFactor(name: "Red de apoyo", order: 4),
        EmotionalFactor(name: "Estrés / Angustia", order: 5)
    ]
}
