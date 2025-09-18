import SwiftUI
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var weatherService = WeatherService()
    @State private var showingLocationPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: backgroundColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Location Header
                        locationHeader
                        
                        if weatherService.isLoading {
                            loadingView
                        } else if let weather = weatherService.currentWeather {
                            // Main Weather Info
                            mainWeatherCard(weather: weather)
                            
                            // Weather Details Grid
                            weatherDetailsGrid(weather: weather)
                            
                            // Hourly Forecast (if available)
                            if !weatherService.forecast.isEmpty,
                               let firstDay = weatherService.forecast.first {
                                hourlyForecastCard(hourlyData: firstDay.hourly)
                            }
                        } else if let errorMessage = weatherService.errorMessage {
                            errorView(message: errorMessage)
                        } else {
                            emptyStateView
                        }
                    }
                    .padding()
                }
                .refreshable {
                    refreshWeatherData()
                }
            }
            .navigationTitle("Wetter")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                refreshWeatherData()
            }
            .onChange(of: locationManager.currentLocation) { oldValue, newValue in
                refreshWeatherData()
            }
        }
    }
    
    // MARK: - Location Header
    private var locationHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Aktueller Standort")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(locationManager.currentAddress)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: { showingLocationPicker = true }) {
                Image(systemName: "location.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView()
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(12)
    }
    
    // MARK: - Main Weather Card
    private func mainWeatherCard(weather: CurrentWeather) -> some View {
        VStack(spacing: 16) {
            // Weather Icon
            Image(systemName: weatherService.getWeatherIcon(for: weather.condition))
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(radius: 10)
            
            // Temperature
            Text(settingsManager.formatTemperature(weather.temperature))
                .font(.system(size: 72, weight: .thin))
                .foregroundColor(.white)
            
            // Condition
            Text(weather.condition.text)
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
            
            // Feels Like
            Text("Gefühlt wie \(settingsManager.formatTemperature(weather.feelsLike))")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
    
    // MARK: - Weather Details Grid
    private func weatherDetailsGrid(weather: CurrentWeather) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            WeatherDetailCard(
                title: "UV-Index",
                value: String(format: "%.0f", weather.uvIndex),
                subtitle: weatherService.getUVIndexDescription(for: weather.uvIndex),
                icon: "sun.max.fill",
                color: Color(weatherService.getUVIndexColor(for: weather.uvIndex))
            )
            
            WeatherDetailCard(
                title: "Luftfeuchtigkeit",
                value: "\(weather.humidity)%",
                subtitle: "Relative Feuchte",
                icon: "humidity.fill",
                color: .blue
            )
            
            WeatherDetailCard(
                title: "Sicht",
                value: settingsManager.formatDistance(weather.visibility),
                subtitle: "Sichtweite",
                icon: "eye.fill",
                color: .green
            )
            
            WeatherDetailCard(
                title: "Wind",
                value: settingsManager.formatSpeed(weather.windSpeed),
                subtitle: "Geschwindigkeit",
                icon: "wind",
                color: .cyan
            )
            
            WeatherDetailCard(
                title: "Luftdruck",
                value: settingsManager.formatPressure(weather.pressure),
                subtitle: "Atmosphärisch",
                icon: "barometer",
                color: .purple
            )
            
            WeatherDetailCard(
                title: "Windrichtung",
                value: "\(weather.windDirection)°",
                subtitle: windDirectionText(weather.windDirection),
                icon: "location.north.fill",
                color: .orange
            )
        }
    }
    
    // MARK: - Hourly Forecast Card
    private func hourlyForecastCard(hourlyData: [HourlyWeather]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stündliche Vorhersage")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(hourlyData.prefix(24)) { hour in
                        HourlyWeatherCard(
                            hour: hour,
                            settingsManager: settingsManager,
                            weatherService: weatherService
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("Wetterdaten werden geladen...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(height: 200)
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Fehler")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Erneut versuchen") {
                refreshWeatherData()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(25)
        }
        .frame(height: 200)
        .padding()
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Kein Standort verfügbar")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Aktivieren Sie die Standortdienste, um Wetterdaten zu erhalten.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Standort aktivieren") {
                locationManager.requestLocationPermission()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(25)
        }
        .frame(height: 200)
        .padding()
    }
    
    // MARK: - Helper Methods
    private var backgroundColors: [Color] {
        if let weather = weatherService.currentWeather {
            return backgroundColorsForCondition(weather.condition.code)
        }
        return [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]
    }
    
    private func backgroundColorsForCondition(_ code: Int) -> [Color] {
        switch code {
        case 1000: // Clear/Sunny
            return [Color.orange.opacity(0.8), Color.yellow.opacity(0.6)]
        case 1003, 1006: // Partly cloudy, Cloudy
            return [Color.gray.opacity(0.8), Color.blue.opacity(0.6)]
        case 1063, 1180...1195: // Rain
            return [Color.blue.opacity(0.8), Color.gray.opacity(0.6)]
        case 1066, 1210...1225: // Snow
            return [Color.white.opacity(0.8), Color.blue.opacity(0.6)]
        case 1087, 1273...1282: // Thunder
            return [Color.purple.opacity(0.8), Color.black.opacity(0.6)]
        default:
            return [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]
        }
    }
    
    private func refreshWeatherData() {
        guard let location = locationManager.currentLocation else {
            // Fallback: Load mock data if no location is available
            print("No location available, loading mock data")
            weatherService.loadMockData()
            return
        }
        
        weatherService.fetchForecast(for: location.coordinate)
    }
    
    private func windDirectionText(_ degrees: Int) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((Double(degrees) + 11.25) / 22.5) % 16
        return directions[index]
    }
}

// MARK: - Weather Detail Card
struct WeatherDetailCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(12)
    }
}

// MARK: - Hourly Weather Card
struct HourlyWeatherCard: View {
    let hour: HourlyWeather
    let settingsManager: SettingsManager
    let weatherService: WeatherService
    
    var body: some View {
        VStack(spacing: 8) {
            Text(formatHour(hour.time))
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Image(systemName: weatherService.getWeatherIcon(for: hour.condition))
                .font(.title3)
                .foregroundColor(.white)
            
            Text(settingsManager.formatTemperature(hour.temperature))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            if hour.chanceOfRain > 0 {
                Text("\(hour.chanceOfRain)%")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
    
    private func formatHour(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let date = formatter.date(from: timeString) {
            let hourFormatter = DateFormatter()
            hourFormatter.dateFormat = "HH:mm"
            return hourFormatter.string(from: date)
        }
        return timeString
    }
}

// MARK: - Location Picker View
struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var weatherService = WeatherService()
    
    @State private var searchText = ""
    @State private var searchResults: [City] = []
    @State private var isSearching = false
    @State private var savedLocations: [SavedLocation] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Content
                if isSearching {
                    loadingView
                } else if !searchResults.isEmpty {
                    searchResultsList
                } else if !savedLocations.isEmpty {
                    savedLocationsList
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Standort wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: useCurrentLocation) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Aktuell")
                        }
                    }
                }
            }
            .onAppear {
                loadSavedLocations()
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Stadt suchen...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        searchCities()
                    }
                    .onChange(of: searchText) { oldValue, newValue in
                        if newValue.isEmpty {
                            searchResults = []
                        } else if newValue.count > 2 {
                            searchCities()
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
            Text("Suche...")
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Search Results List
    private var searchResultsList: some View {
        List(searchResults) { city in
            CityRowView(city: city) {
                selectLocation(city)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Saved Locations List
    private var savedLocationsList: some View {
        List {
            Section("Gespeicherte Standorte") {
                ForEach(savedLocations) { location in
                    SavedLocationRowView(location: location) {
                        selectSavedLocation(location)
                    }
                }
                .onDelete(perform: deleteSavedLocation)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Standort suchen")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Geben Sie eine Stadt ein, um nach Standorten zu suchen, oder verwenden Sie Ihren aktuellen Standort.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    private func searchCities() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isSearching = true
        
        weatherService.searchCities(query: searchText) { results in
            DispatchQueue.main.async {
                self.searchResults = results
                self.isSearching = false
            }
        }
    }
    
    private func clearSearch() {
        searchText = ""
        searchResults = []
    }
    
    private func useCurrentLocation() {
        locationManager.requestLocation()
        dismiss()
    }
    
    private func selectLocation(_ city: City) {
        let coordinate = CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude)
        locationManager.setCustomLocation(coordinate: coordinate, address: "\(city.name), \(city.country)")
        
        // Save location
        let savedLocation = SavedLocation(
            name: city.name,
            country: city.country,
            coordinate: coordinate
        )
        saveLocation(savedLocation)
        
        dismiss()
    }
    
    private func selectSavedLocation(_ location: SavedLocation) {
        locationManager.setCustomLocation(coordinate: location.coordinate, address: "\(location.name), \(location.country)")
        dismiss()
    }
    
    private func loadSavedLocations() {
        savedLocations = settingsManager.getSavedLocations()
    }
    
    private func saveLocation(_ location: SavedLocation) {
        settingsManager.addLocation(location)
        loadSavedLocations()
    }
    
    private func deleteSavedLocation(at offsets: IndexSet) {
        for index in offsets {
            settingsManager.removeLocation(savedLocations[index])
        }
        loadSavedLocations()
    }
}

// MARK: - City Row View
struct CityRowView: View {
    let city: City
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(city.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(city.region), \(city.country)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Saved Location Row View
struct SavedLocationRowView: View {
    let location: SavedLocation
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(location.country)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .environmentObject(LocationManager())
        .environmentObject(SettingsManager())
}
