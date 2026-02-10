import Foundation
import Observation

@Observable
@MainActor
final class SettingsViewModel {
    var factors: [EmotionalFactor] = []
    var notificationSettings = NotificationSettingsManager.shared.settings
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?
    
    init() {
        // Data loading deferred to onAppear in the view
    }
    
    func loadFactors() {
        isLoading = true
        
        do {
            self.factors = try DataRepository.shared.getAllFactors()
            self.isLoading = false
        } catch {
            self.errorMessage = "Error al cargar factores: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    // MARK: - Factor Management
    
    func addFactor(_ name: String) {
        let newFactor = EmotionalFactor(name: name, order: factors.count, isCustom: true)
        
        do {
            try DataRepository.shared.addFactor(newFactor)
            factors.append(newFactor)
            self.successMessage = "Factor añadido correctamente"
        } catch {
            self.errorMessage = "Error al añadir factor: \(error.localizedDescription)"
        }
    }
    
    func updateFactor(_ factor: EmotionalFactor, newName: String) {
        factor.name = newName
        
        do {
            try DataRepository.shared.updateFactor(factor)
            self.successMessage = "Factor actualizado correctamente"
        } catch {
            self.errorMessage = "Error al actualizar factor: \(error.localizedDescription)"
        }
    }
    
    func deleteFactor(_ factor: EmotionalFactor) {
        do {
            try DataRepository.shared.deleteFactor(factor)
            factors.removeAll { $0.id == factor.id }
            self.successMessage = "Factor eliminado correctamente"
        } catch {
            self.errorMessage = "Error al eliminar factor: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Notification Settings
    
    func updateNotificationTime(hour: Int, minute: Int) {
        notificationSettings.hour = hour
        notificationSettings.minute = minute
        NotificationSettingsManager.shared.settings = notificationSettings
        
        if notificationSettings.isEnabled {
            NotificationManager.shared.scheduleNotification(at: hour, minute: minute)
            self.successMessage = "Recordatorio programado para las \(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
        }
    }
    
    func toggleNotifications(_ enabled: Bool) {
        notificationSettings.isEnabled = enabled
        NotificationSettingsManager.shared.settings = notificationSettings
        
        if enabled {
            NotificationManager.shared.scheduleNotification(
                at: notificationSettings.hour,
                minute: notificationSettings.minute
            )
            self.successMessage = "Recordatorios activados"
        } else {
            NotificationManager.shared.cancelNotifications()
            self.successMessage = "Recordatorios desactivados"
        }
    }
}
