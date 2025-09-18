import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var currentAddress: String = "Standort wird ermittelt..."
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update location every 100 meters
        
        authorizationStatus = locationManager.authorizationStatus
        isLocationEnabled = authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            errorMessage = "Standortzugriff verweigert. Bitte aktivieren Sie ihn in den Einstellungen."
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        if !isLocationEnabled {
            requestLocationPermission()
        } else {
            startLocationUpdates()
        }
    }
    
    func startLocationUpdates() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse || 
              locationManager.authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func setCustomLocation(coordinate: CLLocationCoordinate2D, address: String) {
        let customLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.currentLocation = customLocation
        self.currentAddress = address
    }
    
    func getCurrentLocationName(completion: @escaping (String) -> Void) {
        guard let location = currentLocation else {
            completion("Unbekannter Standort")
            return
        }
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Reverse geocoding error: \(error)")
                    completion("Unbekannter Standort")
                    return
                }
                
                if let placemark = placemarks?.first {
                    let city = placemark.locality ?? ""
                    let country = placemark.country ?? ""
                    let address = city.isEmpty ? country : "\(city), \(country)"
                    completion(address.isEmpty ? "Unbekannter Standort" : address)
                } else {
                    completion("Unbekannter Standort")
                }
            }
        }
    }
    
    func getAddressFromCoordinate(_ coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Reverse geocoding error: \(error)")
                    completion("Unbekannter Standort")
                    return
                }
                
                if let placemark = placemarks?.first {
                    let city = placemark.locality ?? ""
                    let region = placemark.administrativeArea ?? ""
                    let country = placemark.country ?? ""
                    
                    var address = ""
                    if !city.isEmpty {
                        address = city
                        if !region.isEmpty && region != city {
                            address += ", \(region)"
                        }
                        if !country.isEmpty {
                            address += ", \(country)"
                        }
                    } else if !region.isEmpty {
                        address = region
                        if !country.isEmpty {
                            address += ", \(country)"
                        }
                    } else {
                        address = country
                    }
                    
                    completion(address.isEmpty ? "Unbekannter Standort" : address)
                } else {
                    completion("Unbekannter Standort")
                }
            }
        }
    }
    
    private func updateCurrentAddress() {
        getCurrentLocationName { [weak self] address in
            self?.currentAddress = address
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.errorMessage = nil
            self.updateCurrentAddress()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Standort konnte nicht ermittelt werden: \(error.localizedDescription)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            self.isLocationEnabled = status == .authorizedWhenInUse || status == .authorizedAlways
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startLocationUpdates()
                self.errorMessage = nil
            case .denied:
                self.errorMessage = "Standortzugriff verweigert. Aktivieren Sie ihn in den App-Einstellungen."
            case .restricted:
                self.errorMessage = "Standortzugriff ist eingeschränkt."
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
}
