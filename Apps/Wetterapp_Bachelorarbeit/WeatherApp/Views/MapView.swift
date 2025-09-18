import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var weatherService = WeatherService()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedLocationWeather: CurrentWeather?
    @State private var showingLocationDetails = false
    @State private var searchText = ""
    @State private var searchResults: [City] = []
    @State private var showingSearchResults = false
    @State private var selectedLocationName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        WeatherMapAnnotation(
                            weather: annotation.weather,
                            settingsManager: settingsManager,
                            isSelected: selectedCoordinate?.latitude == annotation.coordinate.latitude &&
                                       selectedCoordinate?.longitude == annotation.coordinate.longitude
                        )
                        .onTapGesture {
                            selectLocation(annotation.coordinate, name: annotation.name)
                        }
                    }
                }
                .onTapGesture { location in
                    let coordinate = region.center
                    selectLocationFromTap(coordinate)
                }
                .ignoresSafeArea()
                
                VStack {
                    searchBar
                    
                    if showingSearchResults {
                        searchResultsList
                    }
                    
                    Spacer()
                    
                    if showingLocationDetails {
                        locationDetailsCard
                            .transition(.move(edge: .bottom))
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Karte")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                updateRegionToCurrentLocation()
            }
            .onChange(of: locationManager.currentLocation) { oldValue, newValue in
                updateRegionToCurrentLocation()
            }
        }
    }
    
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
                            showingSearchResults = false
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
            .background(Color(.systemBackground))
        }
    }
    
    private var searchResultsList: some View {
        List(searchResults) { city in
            Button(action: {
                selectCityFromSearch(city)
            }) {
                VStack(alignment: .leading) {
                    Text(city.name)
                        .font(.headline)
                    Text("\(city.region), \(city.country)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxHeight: 200)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
    
    private var locationDetailsCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(selectedLocationName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let weather = selectedLocationWeather {
                        Text(weather.condition.text)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button("Schließen") {
                    withAnimation {
                        showingLocationDetails = false
                    }
                }
                .foregroundColor(.blue)
            }
            
            if let weather = selectedLocationWeather {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Temperatur")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(weather.temperature))°C")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Luftfeuchtigkeit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(weather.humidity)%")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private var annotations: [WeatherAnnotation] {
        var result: [WeatherAnnotation] = []
        
        if let currentLocation = locationManager.currentLocation,
           let currentWeather = weatherService.currentWeather {
            result.append(WeatherAnnotation(
                coordinate: currentLocation.coordinate,
                weather: currentWeather,
                name: "Aktueller Standort"
            ))
        }
        
        if let selectedCoordinate = selectedCoordinate,
           let selectedWeather = selectedLocationWeather {
            result.append(WeatherAnnotation(
                coordinate: selectedCoordinate,
                weather: selectedWeather,
                name: selectedLocationName
            ))
        }
        
        return result
    }
    
    private func searchCities() {
        guard !searchText.isEmpty else { return }
        
        weatherService.searchCities(query: searchText) { cities in
            self.searchResults = cities
            self.showingSearchResults = !cities.isEmpty
        }
    }
    
    private func clearSearch() {
        searchText = ""
        searchResults = []
        showingSearchResults = false
    }
    
    private func selectCityFromSearch(_ city: City) {
        selectedCoordinate = city.coordinate
        selectedLocationName = city.displayName
        clearSearch()
        
        region = MKCoordinateRegion(
            center: city.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        
        weatherService.fetchCurrentWeather(for: city.coordinate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let weather = weatherService.currentWeather {
                selectedLocationWeather = weather
                withAnimation {
                    showingLocationDetails = true
                }
            }
        }
    }
    
    private func selectLocation(_ coordinate: CLLocationCoordinate2D, name: String) {
        selectedCoordinate = coordinate
        selectedLocationName = name
        
        weatherService.fetchCurrentWeather(for: coordinate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let weather = weatherService.currentWeather {
                selectedLocationWeather = weather
                withAnimation {
                    showingLocationDetails = true
                }
            }
        }
    }
    
    private func selectLocationFromTap(_ coordinate: CLLocationCoordinate2D) {
        selectLocation(coordinate, name: "Ausgewählter Ort")
    }
    
    private func updateRegionToCurrentLocation() {
        if let location = locationManager.currentLocation {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
            
            weatherService.fetchCurrentWeather(for: location.coordinate)
        }
    }
}

struct WeatherAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let weather: CurrentWeather
    let name: String
}

struct WeatherMapAnnotation: View {
    let weather: CurrentWeather
    let settingsManager: SettingsManager
    let isSelected: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                
                VStack(spacing: 2) {
                    Text("\(Int(weather.temperature))")
                        .font(isSelected ? .caption : .caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("°C")
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

#Preview {
    MapView()
        .environmentObject(LocationManager())
        .environmentObject(SettingsManager())
}
