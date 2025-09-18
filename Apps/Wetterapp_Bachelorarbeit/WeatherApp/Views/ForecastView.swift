import SwiftUI
import CoreLocation

struct ForecastView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var weatherService = WeatherService()
    @State private var selectedDay: ForecastDay?
    @State private var showingDayDetails = false
    
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
                } else if weatherService.forecast.isEmpty {
                    emptyStateView
                } else {
                    forecastContent
                }
            }
            .navigationTitle("7-Tage Vorhersage")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                refreshForecastData()
            }
            .onChange(of: locationManager.currentLocation) { oldValue, newValue in
                refreshForecastData()
            }
            .refreshable {
                refreshForecastData()
            }
            .sheet(item: $selectedDay) { day in
                DayDetailView(day: day, settingsManager: settingsManager, weatherService: weatherService)
            }
        }
    }
    
    // MARK: - Forecast Content
    private var forecastContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Location header
                locationHeader
                
                // Today's detailed forecast
                if let today = weatherService.forecast.first {
                    todayDetailCard(today)
                }
                
                // 7-day forecast list
                ForEach(weatherService.forecast) { day in
                    ForecastDayCard(
                        day: day,
                        settingsManager: settingsManager,
                        weatherService: weatherService,
                        isToday: isToday(day.date)
                    )
                    .onTapGesture {
                        selectedDay = day
                        showingDayDetails = true
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Location Header
    private var locationHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Vorhersage für")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(locationManager.currentAddress)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: refreshForecastData) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
    
    // MARK: - Today Detail Card
    private func todayDetailCard(_ today: ForecastDay) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Heute")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(formatDate(today.date))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            HStack(spacing: 20) {
                // Weather icon and condition
                VStack {
                    Image(systemName: weatherService.getWeatherIcon(for: today.day.condition))
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                    
                    Text(today.day.condition.text)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Temperature range
                VStack(alignment: .trailing) {
                    Text(settingsManager.formatTemperature(today.day.maxTemp))
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(settingsManager.formatTemperature(today.day.minTemp))
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Additional details
            HStack(spacing: 20) {
                DetailItem(
                    icon: "drop.fill",
                    value: "\(Int(today.day.totalPrecipitation)) mm",
                    label: "Niederschlag"
                )
                
                DetailItem(
                    icon: "wind",
                    value: settingsManager.formatSpeed(today.day.maxWind),
                    label: "Wind"
                )
                
                DetailItem(
                    icon: "humidity.fill",
                    value: "\(Int(today.day.avgHumidity))%",
                    label: "Feuchtigkeit"
                )
            }
            
            // Sun times
            HStack {
                HStack {
                    Image(systemName: "sunrise.fill")
                        .foregroundColor(.orange)
                    Text("Sonnenaufgang: \(today.astro.sunrise)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "sunset.fill")
                        .foregroundColor(.orange)
                    Text("Sonnenuntergang: \(today.astro.sunset)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
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
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("Vorhersage wird geladen...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Keine Vorhersage verfügbar")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Aktivieren Sie die Standortdienste, um eine Wettervorhersage zu erhalten.")
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
    private func refreshForecastData() {
        guard let location = locationManager.currentLocation else {
            return
        }
        
        weatherService.fetchForecast(for: location.coordinate, days: 7)
    }
    
    private func isToday(_ dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else { return false }
        return Calendar.current.isDateInToday(date)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd. MMMM"
        outputFormatter.locale = Locale(identifier: "de_DE")
        
        return outputFormatter.string(from: date)
    }
}

// MARK: - Forecast Day Card
struct ForecastDayCard: View {
    let day: ForecastDay
    let settingsManager: SettingsManager
    let weatherService: WeatherService
    let isToday: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Day and date
            VStack(alignment: .leading, spacing: 4) {
                Text(isToday ? "Heute" : dayOfWeek(day.date))
                    .font(.headline)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundColor(.white)
                
                Text(formatDate(day.date))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            // Weather icon and condition
            VStack(spacing: 4) {
                Image(systemName: weatherService.getWeatherIcon(for: day.day.condition))
                    .font(.title2)
                    .foregroundColor(.white)
                
                if day.day.totalPrecipitation > 0 {
                    Text("\(Int(day.day.totalPrecipitation))mm")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            .frame(width: 50)
            
            Spacer()
            
            // Temperature range
            HStack(spacing: 8) {
                Text(settingsManager.formatTemperature(day.day.minTemp))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(settingsManager.formatTemperature(day.day.maxTemp))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(isToday ? 0.4 : 0.2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(isToday ? 0.3 : 0), lineWidth: 1)
        )
    }
    
    private func dayOfWeek(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        dayFormatter.locale = Locale(identifier: "de_DE")
        
        return dayFormatter.string(from: date)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd.MM"
        
        return outputFormatter.string(from: date)
    }
}

// MARK: - Detail Item
struct DetailItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Day Detail View
struct DayDetailView: View {
    let day: ForecastDay
    let settingsManager: SettingsManager
    let weatherService: WeatherService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Main day info
                    dayOverview
                    
                    // Hourly forecast
                    hourlyForecast
                    
                    // Detailed metrics
                    detailedMetrics
                    
                    // Astronomy info
                    astronomyInfo
                }
                .padding()
            }
            .navigationTitle(formatFullDate(day.date))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var dayOverview: some View {
        VStack(spacing: 16) {
            Image(systemName: weatherService.getWeatherIcon(for: day.day.condition))
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text(day.day.condition.text)
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                VStack {
                    Text("Maximum")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(settingsManager.formatTemperature(day.day.maxTemp))
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                VStack {
                    Text("Minimum")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(settingsManager.formatTemperature(day.day.minTemp))
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var hourlyForecast: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stündliche Vorhersage")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(day.hourly) { hour in
                        VStack(spacing: 8) {
                            Text(formatHour(hour.time))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Image(systemName: weatherService.getWeatherIcon(for: hour.condition))
                                .font(.title3)
                                .foregroundColor(.blue)
                            
                            Text(settingsManager.formatTemperature(hour.temperature))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if hour.chanceOfRain > 0 {
                                Text("\(hour.chanceOfRain)%")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var detailedMetrics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                MetricCard(
                    icon: "wind",
                    title: "Max. Wind",
                    value: settingsManager.formatSpeed(day.day.maxWind)
                )
                
                MetricCard(
                    icon: "humidity.fill",
                    title: "Ø Feuchtigkeit",
                    value: "\(Int(day.day.avgHumidity))%"
                )
                
                MetricCard(
                    icon: "eye.fill",
                    title: "Ø Sicht",
                    value: settingsManager.formatDistance(day.day.avgVisibility)
                )
                
                MetricCard(
                    icon: "sun.max.fill",
                    title: "UV-Index",
                    value: String(format: "%.0f", day.day.uvIndex)
                )
                
                MetricCard(
                    icon: "drop.fill",
                    title: "Niederschlag",
                    value: "\(Int(day.day.totalPrecipitation)) mm"
                )
                
                MetricCard(
                    icon: "thermometer",
                    title: "Ø Temperatur",
                    value: settingsManager.formatTemperature(day.day.avgTemp)
                )
            }
        }
    }
    
    private var astronomyInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Astronomie")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "sunrise.fill")
                        .foregroundColor(.orange)
                    Text("Sonnenaufgang")
                    Spacer()
                    Text(day.astro.sunrise)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Image(systemName: "sunset.fill")
                        .foregroundColor(.orange)
                    Text("Sonnenuntergang")
                    Spacer()
                    Text(day.astro.sunset)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.gray)
                    Text("Mondphase")
                    Spacer()
                    Text(day.astro.moonPhase)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(.gray)
                    Text("Mondaufgang")
                    Spacer()
                    Text(day.astro.moonrise)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Image(systemName: "moon.zzz.fill")
                        .foregroundColor(.gray)
                    Text("Monduntergang")
                    Spacer()
                    Text(day.astro.moonset)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func formatFullDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEEE, dd. MMMM yyyy"
        outputFormatter.locale = Locale(identifier: "de_DE")
        
        return outputFormatter.string(from: date)
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

// MARK: - Metric Card
struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ForecastView()
        .environmentObject(LocationManager())
        .environmentObject(SettingsManager())
}
