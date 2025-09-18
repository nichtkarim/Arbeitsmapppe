import Foundation
import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    @Published var temperatureUnit: TemperatureUnit = .celsius
    @Published var speedUnit: SpeedUnit = .kmh
    @Published var distanceUnit: DistanceUnit = .km
    @Published var pressureUnit: PressureUnit = .mbar
    @Published var isDarkModeEnabled: Bool = false
    @Published var colorScheme: ColorScheme? = nil
    @Published var isNotificationsEnabled: Bool = false
    @Published var savedLocations: [SavedLocation] = []
    @Published var selectedLocationIndex: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // UserDefaults Keys
    private enum Keys {
        static let temperatureUnit = "temperatureUnit"
        static let speedUnit = "speedUnit"
        static let distanceUnit = "distanceUnit"
        static let pressureUnit = "pressureUnit"
        static let isDarkModeEnabled = "isDarkModeEnabled"
        static let isNotificationsEnabled = "isNotificationsEnabled"
        static let savedLocations = "savedLocations"
        static let selectedLocationIndex = "selectedLocationIndex"
    }
    
    init() {
        loadSettings()
        setupBindings()
    }
    
    private func setupBindings() {
        // Temperature Unit
        $temperatureUnit
            .sink { [weak self] unit in
                self?.userDefaults.set(unit.rawValue, forKey: Keys.temperatureUnit)
            }
            .store(in: &cancellables)
        
        // Speed Unit
        $speedUnit
            .sink { [weak self] unit in
                self?.userDefaults.set(unit.rawValue, forKey: Keys.speedUnit)
            }
            .store(in: &cancellables)
        
        // Distance Unit
        $distanceUnit
            .sink { [weak self] unit in
                self?.userDefaults.set(unit.rawValue, forKey: Keys.distanceUnit)
            }
            .store(in: &cancellables)
        
        // Pressure Unit
        $pressureUnit
            .sink { [weak self] unit in
                self?.userDefaults.set(unit.rawValue, forKey: Keys.pressureUnit)
            }
            .store(in: &cancellables)
        
        // Dark Mode
        $isDarkModeEnabled
            .sink { [weak self] isDarkMode in
                self?.userDefaults.set(isDarkMode, forKey: Keys.isDarkModeEnabled)
                self?.colorScheme = isDarkMode ? .dark : .light
            }
            .store(in: &cancellables)
        
        // Notifications
        $isNotificationsEnabled
            .sink { [weak self] isEnabled in
                self?.userDefaults.set(isEnabled, forKey: Keys.isNotificationsEnabled)
            }
            .store(in: &cancellables)
        
        // Saved Locations
        $savedLocations
            .sink { [weak self] locations in
                self?.saveSavedLocations(locations)
            }
            .store(in: &cancellables)
        
        // Selected Location Index
        $selectedLocationIndex
            .sink { [weak self] index in
                self?.userDefaults.set(index, forKey: Keys.selectedLocationIndex)
            }
            .store(in: &cancellables)
    }
    
    private func loadSettings() {
        // Temperature Unit
        if let temperatureUnitString = userDefaults.object(forKey: Keys.temperatureUnit) as? String,
           let temperatureUnit = TemperatureUnit(rawValue: temperatureUnitString) {
            self.temperatureUnit = temperatureUnit
        }
        
        // Speed Unit
        if let speedUnitString = userDefaults.object(forKey: Keys.speedUnit) as? String,
           let speedUnit = SpeedUnit(rawValue: speedUnitString) {
            self.speedUnit = speedUnit
        }
        
        // Distance Unit
        if let distanceUnitString = userDefaults.object(forKey: Keys.distanceUnit) as? String,
           let distanceUnit = DistanceUnit(rawValue: distanceUnitString) {
            self.distanceUnit = distanceUnit
        }
        
        // Pressure Unit
        if let pressureUnitString = userDefaults.object(forKey: Keys.pressureUnit) as? String,
           let pressureUnit = PressureUnit(rawValue: pressureUnitString) {
            self.pressureUnit = pressureUnit
        }
        
        // Dark Mode
        isDarkModeEnabled = userDefaults.bool(forKey: Keys.isDarkModeEnabled)
        colorScheme = isDarkModeEnabled ? .dark : .light
        
        // Notifications
        isNotificationsEnabled = userDefaults.bool(forKey: Keys.isNotificationsEnabled)
        
        // Saved Locations
        loadSavedLocations()
        
        // Selected Location Index
        selectedLocationIndex = userDefaults.integer(forKey: Keys.selectedLocationIndex)
    }
    
    // MARK: - Temperature Conversion
    func convertTemperature(_ celsius: Double) -> Double {
        switch temperatureUnit {
        case .celsius:
            return celsius
        case .fahrenheit:
            return (celsius * 9/5) + 32
        }
    }
    
    func formatTemperature(_ celsius: Double) -> String {
        let converted = convertTemperature(celsius)
        return String(format: "%.0f%@", converted, temperatureUnit.rawValue)
    }
    
    // MARK: - Speed Conversion
    func convertSpeed(_ kmh: Double) -> Double {
        switch speedUnit {
        case .kmh:
            return kmh
        case .mph:
            return kmh * 0.621371
        case .ms:
            return kmh / 3.6
        }
    }
    
    func formatSpeed(_ kmh: Double) -> String {
        let converted = convertSpeed(kmh)
        return String(format: "%.1f %@", converted, speedUnit.rawValue)
    }
    
    // MARK: - Distance Conversion
    func convertDistance(_ km: Double) -> Double {
        switch distanceUnit {
        case .km:
            return km
        case .miles:
            return km * 0.621371
        }
    }
    
    func formatDistance(_ km: Double) -> String {
        let converted = convertDistance(km)
        return String(format: "%.1f %@", converted, distanceUnit.rawValue)
    }
    
    // MARK: - Pressure Conversion
    func convertPressure(_ mbar: Double) -> Double {
        switch pressureUnit {
        case .mbar:
            return mbar
        case .inHg:
            return mbar * 0.02953
        case .hPa:
            return mbar // mbar and hPa are the same
        }
    }
    
    func formatPressure(_ mbar: Double) -> String {
        let converted = convertPressure(mbar)
        let format = pressureUnit == .inHg ? "%.2f %@" : "%.0f %@"
        return String(format: format, converted, pressureUnit.rawValue)
    }
    
    // MARK: - Saved Locations Management
    func addLocation(_ location: SavedLocation) {
        // Remove duplicates
        savedLocations.removeAll { $0.name == location.name }
        savedLocations.append(location)
    }
    
    func removeLocation(at index: Int) {
        guard index < savedLocations.count else { return }
        savedLocations.remove(at: index)
        
        // Adjust selected index if necessary
        if selectedLocationIndex >= savedLocations.count {
            selectedLocationIndex = max(0, savedLocations.count - 1)
        }
    }
    
    func removeLocation(_ location: SavedLocation) {
        savedLocations.removeAll { $0.id == location.id }
    }
    
    func getSavedLocations() -> [SavedLocation] {
        return savedLocations
    }
    
    func moveLocation(from source: IndexSet, to destination: Int) {
        savedLocations.move(fromOffsets: source, toOffset: destination)
    }
    
    private func saveSavedLocations(_ locations: [SavedLocation]) {
        do {
            let data = try JSONEncoder().encode(locations)
            userDefaults.set(data, forKey: Keys.savedLocations)
        } catch {
            print("Error saving locations: \(error)")
        }
    }
    
    private func loadSavedLocations() {
        guard let data = userDefaults.data(forKey: Keys.savedLocations) else { return }
        
        do {
            savedLocations = try JSONDecoder().decode([SavedLocation].self, from: data)
        } catch {
            print("Error loading locations: \(error)")
            savedLocations = []
        }
    }
    
    // MARK: - Reset Settings
    func resetToDefaults() {
        temperatureUnit = .celsius
        speedUnit = .kmh
        distanceUnit = .km
        pressureUnit = .mbar
        isDarkModeEnabled = false
        isNotificationsEnabled = false
        savedLocations = []
        selectedLocationIndex = 0
    }
    
    // MARK: - Theme Management
    func toggleDarkMode() {
        isDarkModeEnabled.toggle()
    }
    
    func setColorScheme(_ scheme: ColorScheme?) {
        switch scheme {
        case .dark:
            isDarkModeEnabled = true
        case .light:
            isDarkModeEnabled = false
        case nil:
            // System default - you could implement system detection here
            isDarkModeEnabled = false
        @unknown default:
            isDarkModeEnabled = false
        }
    }
}
