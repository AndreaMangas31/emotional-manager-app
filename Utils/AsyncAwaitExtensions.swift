import Foundation

// MARK: - Async Wrapper Helpers

// Nota: DataRepository ya tiene métodos síncronos.
// Si necesitas usarlos en contexto async, puedes envolver así:
// 
// await MainActor.run {
//     let entries = try DataRepository.shared.getAllEntries()
// }
//
// O simplemente usa los métodos síncronos directamente si estás en MainActor
