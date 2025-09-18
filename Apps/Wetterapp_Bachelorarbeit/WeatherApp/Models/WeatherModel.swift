import Foundation
import CoreLocation

// MARK: - Weather Response Models
struct WeatherResponse: Codable {
    let current: CurrentWeather
    let forecast: ForecastResponse
}

struct CurrentWeatherResponse: Codable {
    let current: CurrentWeather
    let location: Location
}

struct CurrentWeather: Codable {
    let temperature: Double
    let humidity: Int
    let uvIndex: Double
    let visibility: Double
    let windSpeed: Double
    let windDirection: Int
    let pressure: Double
    let feelsLike: Double
    let condition: WeatherCondition
    
    init(temperature: Double, humidity: Int, uvIndex: Double, visibility: Double, windSpeed: Double, windDirection: Int, pressure: Double, feelsLike: Double, condition: WeatherCondition) {
        self.temperature = temperature
        self.humidity = humidity
        self.uvIndex = uvIndex
        self.visibility = visibility
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.pressure = pressure
        self.feelsLike = feelsLike
        self.condition = condition
    }
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp_c"
        case humidity
        case uvIndex = "uv"
        case visibility = "vis_km"
        case windSpeed = "wind_kph"
        case windDirection = "wind_degree"
        case pressure = "pressure_mb"
        case feelsLike = "feelslike_c"
        case condition
    }
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int
    
    init(text: String, icon: String, code: Int) {
        self.text = text
        self.icon = icon
        self.code = code
    }
}

struct Location: Codable, Equatable {
    let name: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double
    let timezone: String
    let localtime: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case region
        case country
        case latitude = "lat"
        case longitude = "lon"
        case timezone = "tz_id"
        case localtime
    }
}

struct ForecastResponse: Codable {
    let forecastDays: [ForecastDay]
    
    enum CodingKeys: String, CodingKey {
        case forecastDays = "forecastday"
    }
}

struct ForecastDay: Codable, Identifiable {
    let id = UUID()
    let date: String
    let day: DayWeather
    let astro: Astro
    let hourly: [HourlyWeather]
    
    enum CodingKeys: String, CodingKey {
        case date
        case day
        case astro
        case hourly = "hour"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(String.self, forKey: .date)
        self.day = try container.decode(DayWeather.self, forKey: .day)
        self.astro = try container.decode(Astro.self, forKey: .astro)
        self.hourly = try container.decode([HourlyWeather].self, forKey: .hourly)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(day, forKey: .day)
        try container.encode(astro, forKey: .astro)
        try container.encode(hourly, forKey: .hourly)
    }
}

struct DayWeather: Codable {
    let maxTemp: Double
    let minTemp: Double
    let avgTemp: Double
    let maxWind: Double
    let totalPrecipitation: Double
    let avgVisibility: Double
    let avgHumidity: Double
    let uvIndex: Double
    let condition: WeatherCondition
    
    enum CodingKeys: String, CodingKey {
        case maxTemp = "maxtemp_c"
        case minTemp = "mintemp_c"
        case avgTemp = "avgtemp_c"
        case maxWind = "maxwind_kph"
        case totalPrecipitation = "totalprecip_mm"
        case avgVisibility = "avgvis_km"
        case avgHumidity = "avghumidity"
        case uvIndex = "uv"
        case condition
    }
}

struct HourlyWeather: Codable, Identifiable {
    let id = UUID()
    let time: String
    let temperature: Double
    let condition: WeatherCondition
    let windSpeed: Double
    let humidity: Int
    let uvIndex: Double
    let visibility: Double
    let pressure: Double
    let chanceOfRain: Int
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temp_c"
        case condition
        case windSpeed = "wind_kph"
        case humidity
        case uvIndex = "uv"
        case visibility = "vis_km"
        case pressure = "pressure_mb"
        case chanceOfRain = "chance_of_rain"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.time = try container.decode(String.self, forKey: .time)
        self.temperature = try container.decode(Double.self, forKey: .temperature)
        self.condition = try container.decode(WeatherCondition.self, forKey: .condition)
        self.windSpeed = try container.decode(Double.self, forKey: .windSpeed)
        self.humidity = try container.decode(Int.self, forKey: .humidity)
        self.uvIndex = try container.decode(Double.self, forKey: .uvIndex)
        self.visibility = try container.decode(Double.self, forKey: .visibility)
        self.pressure = try container.decode(Double.self, forKey: .pressure)
        self.chanceOfRain = try container.decode(Int.self, forKey: .chanceOfRain)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(time, forKey: .time)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(condition, forKey: .condition)
        try container.encode(windSpeed, forKey: .windSpeed)
        try container.encode(humidity, forKey: .humidity)
        try container.encode(uvIndex, forKey: .uvIndex)
        try container.encode(visibility, forKey: .visibility)
        try container.encode(pressure, forKey: .pressure)
        try container.encode(chanceOfRain, forKey: .chanceOfRain)
    }
}

struct Astro: Codable {
    let sunrise: String
    let sunset: String
    let moonrise: String
    let moonset: String
    let moonPhase: String
    
    enum CodingKeys: String, CodingKey {
        case sunrise
        case sunset
        case moonrise
        case moonset
        case moonPhase = "moon_phase"
    }
}

// MARK: - City Search Models
struct CitySearchResponse: Codable {
    let cities: [City]
}

struct City: Codable, Identifiable {
    let id = UUID()
    let name: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case name
        case region
        case country
        case latitude = "lat"
        case longitude = "lon"
    }
    
    init(name: String, region: String, country: String, latitude: Double, longitude: Double) {
        self.name = name
        self.region = region
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.region = try container.decode(String.self, forKey: .region)
        self.country = try container.decode(String.self, forKey: .country)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(region, forKey: .region)
        try container.encode(country, forKey: .country)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    var displayName: String {
        return "\(name), \(region), \(country)"
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - App Models
struct SavedLocation: Codable, Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let coordinate: CLLocationCoordinate2D
    let isCurrentLocation: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, country, latitude, longitude, isCurrentLocation
    }
    
    init(name: String, country: String, coordinate: CLLocationCoordinate2D, isCurrentLocation: Bool = false) {
        self.name = name
        self.country = country
        self.coordinate = coordinate
        self.isCurrentLocation = isCurrentLocation
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        isCurrentLocation = try container.decode(Bool.self, forKey: .isCurrentLocation)
        
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(country, forKey: .country)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(isCurrentLocation, forKey: .isCurrentLocation)
    }
}

// MARK: - Temperature Unit
enum TemperatureUnit: String, CaseIterable, Codable {
    case celsius = "°C"
    case fahrenheit = "°F"
    
    var displayName: String {
        switch self {
        case .celsius:
            return "Celsius (°C)"
        case .fahrenheit:
            return "Fahrenheit (°F)"
        }
    }
}

// MARK: - Speed Unit
enum SpeedUnit: String, CaseIterable, Codable {
    case kmh = "km/h"
    case mph = "mph"
    case ms = "m/s"
    
    var displayName: String {
        switch self {
        case .kmh:
            return "Kilometer/Stunde (km/h)"
        case .mph:
            return "Meilen/Stunde (mph)"
        case .ms:
            return "Meter/Sekunde (m/s)"
        }
    }
}

// MARK: - Distance Unit
enum DistanceUnit: String, CaseIterable, Codable {
    case km = "km"
    case miles = "mi"
    
    var displayName: String {
        switch self {
        case .km:
            return "Kilometer (km)"
        case .miles:
            return "Meilen (mi)"
        }
    }
}

// MARK: - Pressure Unit
enum PressureUnit: String, CaseIterable, Codable {
    case mbar = "mbar"
    case inHg = "inHg"
    case hPa = "hPa"
    
    var displayName: String {
        switch self {
        case .mbar:
            return "Millibar (mbar)"
        case .inHg:
            return "Zoll Quecksilber (inHg)"
        case .hPa:
            return "Hektopascal (hPa)"
        }
    }
}
