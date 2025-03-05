import SwiftUI
import Firebase
import GoogleMaps
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize Google Maps
        GMSServices.provideAPIKey("AIzaSyCSg9CzJzBCM9TBFPutyls-8NDHb-gePRA")

        return true
    }
}

@main
struct MapMotionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    MapView(isLoggedIn: $isLoggedIn)
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
            .onAppear {
                isLoggedIn = Auth.auth().currentUser != nil
            }
        }
    }
}
