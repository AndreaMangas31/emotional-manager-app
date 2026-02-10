import Foundation

class NotificationSettingsManager {
    static let shared = NotificationSettingsManager()
    
    private let defaults = UserDefaults.standard
    private let notificationSettingsKey = "notificationSettings"
    
    var settings: NotificationSettings {
        get {
            if let data = defaults.data(forKey: notificationSettingsKey),
               let decoded = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
                return decoded
            }
            return NotificationSettings()
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                defaults.set(encoded, forKey: notificationSettingsKey)
            }
        }
    }
    
    func updateTime(hour: Int, minute: Int) {
        var currentSettings = settings
        currentSettings.hour = hour
        currentSettings.minute = minute
        settings = currentSettings
    }
    
    func toggleNotifications(_ enabled: Bool) {
        var currentSettings = settings
        currentSettings.isEnabled = enabled
        settings = currentSettings
    }
}
