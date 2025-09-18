import SwiftUI
import CoreLocation
import Combine

struct DetailsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var weatherService = WeatherService()
    @State private var selectedMetric: WeatherMetric = .temperature
    @State private var currentLocation: Location?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if weatherService.isLoading {
                    loadingView
                } else if let weather = weatherService.currentWeather {
                    detailsContent(weather: weather)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Wetter Details")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                refreshWeatherData()
                // Setze die aktuelle Location, falls bereits verfügbar
                currentLocation = weatherService.currentLocation
            }
            .onChange(of: locationManager.currentLocation) { oldValue, newValue in
                refreshWeatherData()
            }
            .onReceive(weatherService.$currentLocation) { newLocation in
                currentLocation = newLocation
            }
            .refreshable {
                refreshWeatherData()
            }
        }
    }
    
    // MARK: - Details Content
    private func detailsContent(weather: CurrentWeather) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Location and current conditions
                currentConditionsCard(weather: weather)
                
                // Metric selector
                metricSelector
                
                // Detailed metric display
                metricDetailCard(weather: weather)
                
                // All metrics overview
                allMetricsGrid(weather: weather)
                
                // Additional information
                additionalInfoCard(weather: weather)
            }
            .padding()
        }
    }
    
    // MARK: - Current Conditions Card
    private func currentConditionsCard(weather: CurrentWeather) -> some View {
        VStack(spacing: 16) {
            // Location
            Text(locationManager.currentAddress)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Main weather display
            HStack(spacing: 30) {
                VStack {
                    Image(systemName: weatherService.getWeatherIcon(for: weather.condition))
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text(weather.condition.text)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(settingsManager.formatTemperature(weather.temperature))
                        .font(.system(size: 48, weight: .thin))
                        .foregroundColor(.white)
                    
                    Text("Gefühlt wie \(settingsManager.formatTemperature(weather.feelsLike))")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Last updated
            Text("Zuletzt aktualisiert: \(formatCurrentTime())")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
    
    // MARK: - Metric Selector
    private var metricSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(WeatherMetric.allCases, id: \.self) { metric in
                    Button(action: { selectedMetric = metric }) {
                        VStack(spacing: 4) {
                            Image(systemName: metric.icon)
                                .font(.title3)
                            
                            Text(metric.title)
                                .font(.caption)
                        }
                        .foregroundColor(selectedMetric == metric ? .white : .white.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMetric == metric ? Color.blue : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Metric Detail Card
    private func metricDetailCard(weather: CurrentWeather) -> some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: selectedMetric.icon)
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(selectedMetric.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(selectedMetric.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Main value display
            VStack(spacing: 8) {
                Text(getMetricValue(for: selectedMetric, weather: weather))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(getMetricUnit(for: selectedMetric))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical)
            
            // Interpretation
            VStack(alignment: .leading, spacing: 8) {
                Text("Bewertung")
                    .font(.headline)
                
                Text(getMetricInterpretation(for: selectedMetric, weather: weather))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Visual indicator (progress bar or gauge)
            metricVisualIndicator(for: selectedMetric, weather: weather)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - All Metrics Grid
    private func allMetricsGrid(weather: CurrentWeather) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Alle Messwerte")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(WeatherMetric.allCases, id: \.self) { metric in
                    DetailMetricCard(
                        metric: metric,
                        value: getMetricValue(for: metric, weather: weather),
                        unit: getMetricUnit(for: metric),
                        settingsManager: settingsManager
                    )
                    .onTapGesture {
                        selectedMetric = metric
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
    
    // MARK: - Additional Info Card
    private func additionalInfoCard(weather: CurrentWeather) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Zusätzliche Informationen")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                if let location = currentLocation {
                    InfoRow(
                        icon: "location.fill",
                        title: "Koordinaten",
                        value: String(format: "%.4f°, %.4f°", location.latitude, location.longitude)
                    )
                    
                    InfoRow(
                        icon: "clock.fill",
                        title: "Zeitzone",
                        value: location.timezone
                    )
                    
                    InfoRow(
                        icon: "globe",
                        title: "Region",
                        value: "\(location.region), \(location.country)"
                    )
                    
                    InfoRow(
                        icon: "calendar",
                        title: "Lokale Zeit",
                        value: formatLocalTime(location.localtime)
                    )
                } else {
                    Text("Standortinformationen werden geladen...")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
    
    // MARK: - Metric Visual Indicator
    private func metricVisualIndicator(for metric: WeatherMetric, weather: CurrentWeather) -> some View {
        VStack(spacing: 8) {
            switch metric {
            case .uvIndex:
                uvIndexGauge(weather.uvIndex)
            case .humidity:
                humidityGauge(Double(weather.humidity))
            case .visibility:
                visibilityGauge(weather.visibility)
            case .pressure:
                pressureGauge(weather.pressure)
            case .windSpeed:
                windSpeedGauge(weather.windSpeed)
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Gauges
    private func uvIndexGauge(_ uvIndex: Double) -> some View {
        VStack {
            ProgressView(value: min(uvIndex, 11), total: 11)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(weatherService.getUVIndexColor(for: uvIndex))))
                .scaleEffect(1.0, anchor: .center)
            
            HStack {
                Text("0")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("11+")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func humidityGauge(_ humidity: Double) -> some View {
        VStack {
            ProgressView(value: humidity, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            HStack {
                Text("0%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("100%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func visibilityGauge(_ visibility: Double) -> some View {
        VStack {
            ProgressView(value: min(visibility, 20), total: 20)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
            
            HStack {
                Text("0 km")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("20+ km")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func pressureGauge(_ pressure: Double) -> some View {
        VStack {
            ProgressView(value: max(0, min(pressure - 950, 100)), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
            
            HStack {
                Text("950 mbar")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("1050 mbar")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func windSpeedGauge(_ windSpeed: Double) -> some View {
        VStack {
            ProgressView(value: min(windSpeed, 120), total: 120)
                .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
            
            HStack {
                Text("0 km/h")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("120+ km/h")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("Detaillierte Wetterdaten werden geladen...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "info.circle")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Keine Details verfügbar")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Aktivieren Sie die Standortdienste, um detaillierte Wetterdaten zu erhalten.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Standort aktivieren") {
                locationManager.requestLocationPermission()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(25)
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    private func refreshWeatherData() {
        guard let location = locationManager.currentLocation else {
            return
        }
        
        weatherService.fetchCurrentWeather(for: location.coordinate)
    }
    
    private func getMetricValue(for metric: WeatherMetric, weather: CurrentWeather) -> String {
        switch metric {
        case .temperature:
            return String(format: "%.1f", settingsManager.convertTemperature(weather.temperature))
        case .feelsLike:
            return String(format: "%.1f", settingsManager.convertTemperature(weather.feelsLike))
        case .humidity:
            return "\(weather.humidity)"
        case .uvIndex:
            return String(format: "%.0f", weather.uvIndex)
        case .visibility:
            return String(format: "%.1f", settingsManager.convertDistance(weather.visibility))
        case .windSpeed:
            return String(format: "%.1f", settingsManager.convertSpeed(weather.windSpeed))
        case .windDirection:
            return "\(weather.windDirection)"
        case .pressure:
            return String(format: "%.0f", settingsManager.convertPressure(weather.pressure))
        }
    }
    
    private func getMetricUnit(for metric: WeatherMetric) -> String {
        switch metric {
        case .temperature, .feelsLike:
            return settingsManager.temperatureUnit.rawValue
        case .humidity:
            return "%"
        case .uvIndex:
            return "Index"
        case .visibility:
            return settingsManager.distanceUnit.rawValue
        case .windSpeed:
            return settingsManager.speedUnit.rawValue
        case .windDirection:
            return "°"
        case .pressure:
            return settingsManager.pressureUnit.rawValue
        }
    }
    
    private func getMetricInterpretation(for metric: WeatherMetric, weather: CurrentWeather) -> String {
        switch metric {
        case .temperature:
            return getTemperatureInterpretation(weather.temperature)
        case .feelsLike:
            return "Die gefühlte Temperatur berücksichtigt Faktoren wie Wind und Luftfeuchtigkeit."
        case .humidity:
            return getHumidityInterpretation(weather.humidity)
        case .uvIndex:
            return "UV-Index: \(weatherService.getUVIndexDescription(for: weather.uvIndex)). \(getUVAdvice(for: weather.uvIndex))"
        case .visibility:
            return getVisibilityInterpretation(weather.visibility)
        case .windSpeed:
            return getWindSpeedInterpretation(weather.windSpeed)
        case .windDirection:
            return "Wind kommt aus \(windDirectionName(weather.windDirection)) Richtung."
        case .pressure:
            return getPressureInterpretation(weather.pressure)
        }
    }
    
    private func getTemperatureInterpretation(_ temp: Double) -> String {
        switch temp {
        case ...0: return "Sehr kalt - Frostgefahr"
        case 0...10: return "Kalt - warme Kleidung empfohlen"
        case 10...20: return "Mild - angenehme Temperatur"
        case 20...30: return "Warm - ideales Wetter"
        case 30...: return "Heiß - bleiben Sie hydratisiert"
        default: return ""
        }
    }
    
    private func getHumidityInterpretation(_ humidity: Int) -> String {
        switch humidity {
        case ...30: return "Niedrige Luftfeuchtigkeit - kann zu trockener Haut führen"
        case 30...60: return "Optimale Luftfeuchtigkeit für Komfort"
        case 60...80: return "Hohe Luftfeuchtigkeit - kann schwül wirken"
        case 80...: return "Sehr hohe Luftfeuchtigkeit - drückende Atmosphäre"
        default: return ""
        }
    }
    
    private func getVisibilityInterpretation(_ visibility: Double) -> String {
        switch visibility {
        case ...1: return "Sehr schlechte Sicht - Vorsicht im Verkehr"
        case 1...5: return "Eingeschränkte Sicht - erhöhte Aufmerksamkeit nötig"
        case 5...10: return "Gute Sicht - normale Bedingungen"
        case 10...: return "Ausgezeichnete Sicht - klare Bedingungen"
        default: return ""
        }
    }
    
    private func getWindSpeedInterpretation(_ speed: Double) -> String {
        switch speed {
        case ...10: return "Leichter Wind - kaum spürbar"
        case 10...20: return "Mäßiger Wind - angenehm"
        case 20...40: return "Starker Wind - Äste bewegen sich"
        case 40...60: return "Sehr starker Wind - schwierige Bedingungen"
        case 60...: return "Sturmwind - Gefahr für Personen und Gegenstände"
        default: return ""
        }
    }
    
    private func getPressureInterpretation(_ pressure: Double) -> String {
        switch pressure {
        case ...1000: return "Niedriger Luftdruck - oft schlechtes Wetter"
        case 1000...1020: return "Normaler Luftdruck - stabile Bedingungen"
        case 1020...: return "Hoher Luftdruck - meist gutes Wetter"
        default: return ""
        }
    }
    
    private func getUVAdvice(for uvIndex: Double) -> String {
        switch uvIndex {
        case 0...2: return "Minimales Risiko für die meisten Menschen."
        case 3...5: return "Schutz bei längerer Exposition empfohlen."
        case 6...7: return "Schutz erforderlich - Schatten suchen."
        case 8...10: return "Sehr hohes Risiko - extra Schutz nötig."
        default: return "Extremes Risiko - Sonne meiden."
        }
    }
    
    private func windDirectionName(_ degrees: Int) -> String {
        let directions = ["Nord", "Nordnordost", "Nordost", "Ostnordost", "Ost", "Ostsüdost", "Südost", "Südsüdost", "Süd", "Südsüdwest", "Südwest", "Westsüdwest", "West", "Westnordwest", "Nordwest", "Nordnordwest"]
        let index = Int((Double(degrees) + 11.25) / 22.5) % 16
        return directions[index]
    }
    
    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: Date())
    }
    
    private func formatLocalTime(_ localtime: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let date = formatter.date(from: localtime) {
            let outputFormatter = DateFormatter()
            outputFormatter.timeStyle = .short
            outputFormatter.dateStyle = .short
            return outputFormatter.string(from: date)
        }
        return localtime
    }
}

// MARK: - Weather Metric Enum
enum WeatherMetric: CaseIterable {
    case temperature, feelsLike, humidity, uvIndex, visibility, windSpeed, windDirection, pressure
    
    var title: String {
        switch self {
        case .temperature: return "Temperatur"
        case .feelsLike: return "Gefühlt wie"
        case .humidity: return "Feuchtigkeit"
        case .uvIndex: return "UV-Index"
        case .visibility: return "Sicht"
        case .windSpeed: return "Windgeschw."
        case .windDirection: return "Windrichtung"
        case .pressure: return "Luftdruck"
        }
    }
    
    var icon: String {
        switch self {
        case .temperature: return "thermometer"
        case .feelsLike: return "thermometer.variable"
        case .humidity: return "humidity.fill"
        case .uvIndex: return "sun.max.fill"
        case .visibility: return "eye.fill"
        case .windSpeed: return "wind"
        case .windDirection: return "location.north.fill"
        case .pressure: return "barometer"
        }
    }
    
    var description: String {
        switch self {
        case .temperature: return "Aktuelle Lufttemperatur"
        case .feelsLike: return "Gefühlte Temperatur"
        case .humidity: return "Relative Luftfeuchtigkeit"
        case .uvIndex: return "UV-Strahlungsintensität"
        case .visibility: return "Horizontale Sichtweite"
        case .windSpeed: return "Aktuelle Windgeschwindigkeit"
        case .windDirection: return "Windrichtung in Grad"
        case .pressure: return "Atmosphärischer Luftdruck"
        }
    }
}

// MARK: - Detail Metric Card
struct DetailMetricCard: View {
    let metric: WeatherMetric
    let value: String
    let unit: String
    let settingsManager: SettingsManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: metric.icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(metric.title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    DetailsView()
        .environmentObject(LocationManager())
        .environmentObject(SettingsManager())
}
