import SwiftUI
import FirebaseCore
import Shared

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()

        // IMPORTANT: Set the Firebase Auth delegate for the shared KMM module
        // This connects Swift's Firebase SDK to the shared Kotlin business logic
        IOSFirebaseAuth.shared.delegate = FirebaseAuthDelegateImpl.shared

        return true
    }
}

@main
struct iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
