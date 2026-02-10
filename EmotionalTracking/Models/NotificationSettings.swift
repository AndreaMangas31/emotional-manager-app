import Foundation

struct NotificationSettings: Codable {
    var isEnabled: Bool = true
    var hour: Int = 20
    var minute: Int = 0
    var daysOfWeek: Set<Int> = Set(0...6) // 0 = Sunday, 6 = Saturday
    
    var displayTime: String {
        String(format: "%02d:%02d", hour, minute)
    }
}
