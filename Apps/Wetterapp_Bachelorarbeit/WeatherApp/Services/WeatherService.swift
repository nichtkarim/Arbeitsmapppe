import Foundation
import CoreLocation
import Combine

class WeatherService: ObservableObject {
    @Published var currentWeather: CurrentWeather?
    @Published var currentLocation: Location?
    @Published var forecast: [ForecastDay] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = "ccda05f3dbb64e76bfb214340252908" // Test API Key - Ersetze mit deinem WeatherAPI Key
    private let baseURL = "https://api.weatherapi.com/v1"
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Fetch Current Weather
    func fetchCurrentWeather(for coordinate: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil
        
        let urlString = "\(baseURL)/current.json?key=\(apiKey)&q=\(coordinate.latitude),\(coordinate.longitude)&aqi=yes"
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Ungültige URL"
            self.isLoading = false
            return
        }
        
        print("Fetching weather from: \(urlString)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .handleEvents(receiveOutput: { data in
                print("Received data: \(String(data: data, encoding: .utf8) ?? "Could not decode data")")
            })
            .decode(type: CurrentWeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Fehler beim Laden der Wetterdaten: \(error.localizedDescription)"
                        print("Current weather error: \(error)")
                        // Fallback to mock data
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self?.loadMockData()
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    self?.currentWeather = response.current
                    self?.currentLocation = response.location
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Fetch Forecast
    func fetchForecast(for coordinate: CLLocationCoordinate2D, days: Int = 7) {
        isLoading = true
        errorMessage = nil
        
        let urlString = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(coordinate.latitude),\(coordinate.longitude)&days=\(days)&aqi=yes&alerts=yes"
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Ungültige URL"
            self.isLoading = false
            return
        }
        
        print("Fetching forecast from: \(urlString)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .handleEvents(receiveOutput: { data in
                print("Received forecast data: \(String(data: data, encoding: .utf8) ?? "Could not decode data")")
            })
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Fehler beim Laden der Vorhersage: \(error.localizedDescription)"
                        print("Forecast error: \(error)")
                        // Fallback to mock data
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self?.loadMockData()
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    self?.currentWeather = response.current
                    self?.forecast = response.forecast.forecastDays
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Search Cities
    func searchCities(query: String, completion: @escaping ([City]) -> Void) {
        guard !query.isEmpty else {
            completion([])
            return
        }
        
        let urlString = "\(baseURL)/search.json?key=\(apiKey)&q=\(query)"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [City].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Fehler beim Suchen von Städten: \(error)")
                    }
                },
                receiveValue: { cities in
                    completion(cities)
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    func refreshWeatherData(for coordinate: CLLocationCoordinate2D) {
        fetchForecast(for: coordinate)
    }
    
    func getWeatherIcon(for condition: WeatherCondition) -> String {
        switch condition.code {
        case 1000: return "sun.max.fill"
        case 1003: return "cloud.sun.fill"
        case 1006, 1009: return "cloud.fill"
        case 1030, 1135, 1147: return "cloud.fog.fill"
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246: return "cloud.rain.fill"
        case 1066, 1069, 1072, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1237, 1249, 1252, 1255, 1258, 1261, 1264: return "cloud.snow.fill"
        case 1087, 1273, 1276, 1279, 1282: return "cloud.bolt.rain.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    func getUVIndexDescription(for uvIndex: Double) -> String {
        switch uvIndex {
        case 0...2: return "Niedrig"
        case 3...5: return "Mäßig"
        case 6...7: return "Hoch"
        case 8...10: return "Sehr hoch"
        default: return "Extrem"
        }
    }
    
    func getUVIndexColor(for uvIndex: Double) -> String {
        switch uvIndex {
        case 0...2: return "green"
        case 3...5: return "yellow"
        case 6...7: return "orange"
        case 8...10: return "red"
        default: return "purple"
        }
    }
    
    // MARK: - Mock Data for Testing
    func loadMockData() {
        // Create mock weather data when API is not available
        let mockCondition = WeatherCondition(text: "Sonnig", icon: "//cdn.weatherapi.com/weather/64x64/day/113.png", code: 1000)
        
        let mockCurrentWeather = CurrentWeather(
            temperature: 22.5,
            humidity: 65,
            uvIndex: 5.2,
            visibility: 10.0,
            windSpeed: 15.3,
            windDirection: 240,
            pressure: 1013.2,
            feelsLike: 24.1,
            condition: mockCondition
        )
        
        let mockLocation = Location(
            name: "Berlin",
            region: "Berlin",
            country: "Deutschland",
            latitude: 52.5200,
            longitude: 13.4050,
            timezone: "Europe/Berlin",
            localtime: "2025-08-30 15:30"
        )
        
        self.currentWeather = mockCurrentWeather
        self.currentLocation = mockLocation
        self.isLoading = false
        self.errorMessage = nil
        
        print("Mock data loaded successfully")
    }
}
