import SwiftUI
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var showingLocationAlert = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Units Section
                Section(header: Text("Einheiten")) {
                    // Temperature Unit
                    HStack {
                        Image(systemName: "thermometer")
                            .foregroundColor(.red)
                            .frame(width: 25)
                        
                        Text("Temperatur")
                        
                        Spacer()
                        
                        Picker("Temperatur", selection: $settingsManager.temperatureUnit) {
                            ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Speed Unit
                    HStack {
                        Image(systemName: "wind")
                            .foregroundColor(.cyan)
                            .frame(width: 25)
                        
                        Text("Geschwindigkeit")
                        
                        Spacer()
                        
                        Picker("Geschwindigkeit", selection: $settingsManager.speedUnit) {
                            ForEach(SpeedUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Distance Unit
                    HStack {
                        Image(systemName: "ruler")
                            .foregroundColor(.green)
                            .frame(width: 25)
                        
                        Text("Entfernung")
                        
                        Spacer()
                        
                        Picker("Entfernung", selection: $settingsManager.distanceUnit) {
                            ForEach(DistanceUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Pressure Unit
                    HStack {
                        Image(systemName: "barometer")
                            .foregroundColor(.purple)
                            .frame(width: 25)
                        
                        Text("Luftdruck")
                        
                        Spacer()
                        
                        Picker("Luftdruck", selection: $settingsManager.pressureUnit) {
                            ForEach(PressureUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // MARK: - Appearance Section
                Section(header: Text("Darstellung")) {
                    // Dark Mode Toggle
                    HStack {
                        Image(systemName: settingsManager.isDarkModeEnabled ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(settingsManager.isDarkModeEnabled ? .blue : .orange)
                            .frame(width: 25)
                        
                        Text("Dunkles Design")
                        
                        Spacer()
                        
                        Toggle("", isOn: $settingsManager.isDarkModeEnabled)
                    }
                }
                
                // MARK: - Location Section
                Section(header: Text("Standort")) {
                    // Current Location Status
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(locationManager.isLocationEnabled ? .green : .red)
                            .frame(width: 25)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Standortdienste")
                            Text(locationManager.isLocationEnabled ? "Aktiviert" : "Deaktiviert")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !locationManager.isLocationEnabled {
                            Button("Aktivieren") {
                                showingLocationAlert = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // Current Address
                    if locationManager.isLocationEnabled {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 25)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Aktueller Standort")
                                Text(locationManager.currentAddress)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Saved Locations
                    if !settingsManager.savedLocations.isEmpty {
                        NavigationLink(destination: SavedLocationsView()) {
                            HStack {
                                Image(systemName: "bookmark.fill")
                                    .foregroundColor(.orange)
                                    .frame(width: 25)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Gespeicherte Orte")
                                    Text("\(settingsManager.savedLocations.count) Orte")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // MARK: - Notifications Section
                Section(header: Text("Benachrichtigungen")) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .frame(width: 25)
                        
                        Text("Wetter-Benachrichtigungen")
                        
                        Spacer()
                        
                        Toggle("", isOn: $settingsManager.isNotificationsEnabled)
                    }
                }
                
                // MARK: - About Section
                Section(header: Text("Information")) {
                    // App Version
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 25)
                        
                        Text("App Version")
                        
                        Spacer()
                        
                        Text(getAppVersion())
                            .foregroundColor(.secondary)
                    }
                    
                    // Weather Data Source
                    HStack {
                        Image(systemName: "cloud.fill")
                            .foregroundColor(.gray)
                            .frame(width: 25)
                        
                        Text("Wetterdaten")
                        
                        Spacer()
                        
                        Text("WeatherAPI.com")
                            .foregroundColor(.secondary)
                    }
                    
                    // Developer Info
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.green)
                            .frame(width: 25)
                        
                        Text("Entwickelt von")
                        
                        Spacer()
                        
                        Text("Karim")
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - Actions Section
                Section {
                    // Reset Settings
                    Button(action: { showingResetAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.red)
                                .frame(width: 25)
                            
                            Text("Einstellungen zurücksetzen")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .alert("Standortdienste", isPresented: $showingLocationAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Einstellungen öffnen") {
                    openAppSettings()
                }
            } message: {
                Text("Um Standortdienste zu aktivieren, öffnen Sie die App-Einstellungen und gewähren Sie der App Zugriff auf Ihren Standort.")
            }
            .alert("Einstellungen zurücksetzen", isPresented: $showingResetAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Zurücksetzen", role: .destructive) {
                    settingsManager.resetToDefaults()
                }
            } message: {
                Text("Möchten Sie alle Einstellungen auf die Standardwerte zurücksetzen? Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Saved Locations View
struct SavedLocationsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var showingDeleteAlert = false
    @State private var locationToDelete: SavedLocation?
    
    var body: some View {
        List {
            if settingsManager.savedLocations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "location.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("Keine gespeicherten Orte")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Verwenden Sie die Karte, um Orte zu speichern.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
            } else {
                ForEach(settingsManager.savedLocations.indices, id: \.self) { index in
                    let location = settingsManager.savedLocations[index]
                    SavedLocationRow(
                        location: location,
                        isSelected: index == settingsManager.selectedLocationIndex,
                        onSelect: { settingsManager.selectedLocationIndex = index },
                        onDelete: { 
                            locationToDelete = location
                            showingDeleteAlert = true
                        }
                    )
                }
                .onMove(perform: settingsManager.moveLocation)
            }
        }
        .navigationTitle("Gespeicherte Orte")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !settingsManager.savedLocations.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .alert("Ort löschen", isPresented: $showingDeleteAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Löschen", role: .destructive) {
                if let location = locationToDelete,
                   let index = settingsManager.savedLocations.firstIndex(where: { $0.id == location.id }) {
                    settingsManager.removeLocation(at: index)
                }
            }
        } message: {
            Text("Möchten Sie '\(locationToDelete?.name ?? "")' aus den gespeicherten Orten entfernen?")
        }
    }
}

// MARK: - Saved Location Row
struct SavedLocationRow: View {
    let location: SavedLocation
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if location.isCurrentLocation {
                    Text("Aktueller Standort")
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text("Lat: \(location.coordinate.latitude, specifier: "%.4f"), Lng: \(location.coordinate.longitude, specifier: "%.4f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Löschen", role: .destructive) {
                onDelete()
            }
        }
    }
}

// MARK: - Settings Category Header
struct SettingsCategoryHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
        }
        .font(.headline)
    }
}

// MARK: - Settings Row
struct SettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let content: Content
    
    init(
        icon: String,
        iconColor: Color = .blue,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            content
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Unit Picker Row
struct UnitPickerRow<T: CaseIterable & Hashable>: View where T.AllCases.Element == T {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var selection: T
    let options: [T]
    let displayName: (T) -> String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 25)
            
            Text(title)
            
            Spacer()
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(displayName(option)).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
        .environmentObject(LocationManager())
}
