import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Aktuell")
                }
                .tag(0)
            
            ForecastView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Vorhersage")
                }
                .tag(1)
            
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Karte")
                }
                .tag(2)
            
            DetailsView()
                .tabItem {
                    Image(systemName: "info.circle.fill")
                    Text("Details")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Einstellungen")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .onAppear {
            locationManager.requestLocationPermission()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(SettingsManager())
}
