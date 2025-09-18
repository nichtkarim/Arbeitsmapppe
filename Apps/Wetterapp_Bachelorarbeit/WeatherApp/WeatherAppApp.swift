import SwiftUI

@main
struct WeatherAppApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(settingsManager)
                .preferredColorScheme(settingsManager.colorScheme)
        }
    }
}
