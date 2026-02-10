import Foundation
import UserNotifications
#if canImport(UIKit)
import UIKit
#endif

@MainActor
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Permissions
    
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    // MARK: - Schedule Notification
    
    func scheduleNotification(at hour: Int, minute: Int) {
        // Primero, remover todas las notificaciones pendientes
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Crear una notificación diaria en la hora especificada
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Registro emocional"
        content.body = "¿Cómo te sientes hoy? Tómate un momento para completar tu registro."
        content.sound = .default
#if canImport(UIKit)
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
#else
        content.badge = NSNumber(value: 1)
#endif
        
        // Añadir datos personalizados
        content.userInfo = ["type": "daily_reminder", "timestamp": Date().timeIntervalSince1970]
        
        let request = UNNotificationRequest(identifier: "daily_emotional_check", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Mostrar notificación incluso si la app está en primer plano
        completionHandler([.banner, .sound, .badge])
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String, type == "daily_reminder" {
            // La app se abre desde la notificación
            // Se puede acceder a esto desde AppDelegate o SceneDelegate
            NotificationCenter.default.post(name: NSNotification.Name("DailyReminderTapped"), object: nil)
        }
        
        completionHandler()
    }
    
    // MARK: - Get Pending Notifications
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests
    }
    
    // MARK: - Check if notification scheduled
    
    func isNotificationScheduled() async -> Bool {
        let requests = await getPendingNotifications()
        return requests.contains { $0.identifier == "daily_emotional_check" }
    }
}

