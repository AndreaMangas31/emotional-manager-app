import SwiftUI
import SwiftData

@main
struct EmotionalTrackingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let modelContainer: ModelContainer
    
    init() {
        let schema = Schema([
            EmotionalFactor.self,
            DailyEntry.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(modelContainer)
            DataRepository.shared.setModelContext(context)
            print("✅ App initialized successfully")
        } catch {
            print("❌ Failed to initialize ModelContainer: \(error)")
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DailyEntryView()
                .tabItem {
                    Label("Registro", systemImage: "pencil.and.list.clipboard")
                }
                .tag(0)
            
            MetricsView()
                .tabItem {
                    Label("Métricas", systemImage: "chart.bar")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("Historial", systemImage: "calendar")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Configuración", systemImage: "gear")
                }
                .tag(3)
        }
        .preferredColorScheme(nil)
    }
}

// MARK: - AppDelegate
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Solicitar permiso para notificaciones de forma asíncrona
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let notificationManager = NotificationManager.shared
            
            Task {
                let hasPermission = await notificationManager.requestAuthorization()
                if hasPermission {
                    let settings = NotificationSettingsManager.shared.settings
                    if settings.isEnabled {
                        notificationManager.scheduleNotification(at: settings.hour, minute: settings.minute)
                    }
                }
            }
        }
        
        return true
    }
}

// #Preview disabled - requires SwiftData context
// #Preview {
//     ContentView()
// }
