# WeatherApp - iOS 18 Wetter-App

Eine moderne, vollständig funktionsfähige Wetter-App für iOS 18, entwickelt mit Swift und SwiftUI.

## Features

### 🏠 HomeView
- Aktuelle Wetterbedingungen mit schönen Farbverläufen
- Temperatur, UV-Index, Luftfeuchtigkeit, Sicht, Wind und Luftdruck
- Stündliche Vorhersage für die nächsten 24 Stunden
- Automatische Standorterkennung
- Interaktive Wetterkarten mit verschiedenen Wettersymbolen

### 📅 ForecastView
- 7-Tage Wettervorhersage
- Detaillierte Tagesansicht mit Stundenvorhersage
- Sonnenauf- und Sonnenuntergangszeiten
- Mondphasen und Astronomie-Informationen
- Niederschlagswahrscheinlichkeit

### 🗺️ MapView
- Interaktive Karte mit Wetteranzeige
- Stadtsuche mit Autocomplete
- Standort auswählen durch Tippen auf die Karte
- Wetterinformationen für ausgewählte Standorte
- Standorte speichern und verwalten

### 📊 DetailsView
- Detaillierte Analyse aller Wetterdaten
- UV-Index mit Farbcodierung und Empfehlungen
- Luftfeuchtigkeit, Sicht, Wind, Luftdruck
- Visuelle Indikatoren und Bewertungen
- Metrische Auswahl und Interpretation

### ⚙️ SettingsView
- Einheiten umschaltbar (°C/°F, km/h/mph/m/s, km/mi, mbar/inHg/hPa)
- Dark Mode Toggle
- Standortdienste verwalten
- Gespeicherte Orte verwalten
- App-Informationen und Version

## Technische Details

### Architektur
- **MVVM** (Model-View-ViewModel) Pattern
- **SwiftUI** für die Benutzeroberfläche
- **Combine** für reaktive Programmierung
- **CoreLocation** für GPS und Standortdienste
- **MapKit** für Kartenanzeige

### Datenmanagement
- **UserDefaults** für Einstellungen
- **@ObservableObject** und **@Published** für State Management
- **@EnvironmentObject** für App-weite Datenverteilung
- **JSON Codable** für API-Responses

### Services und Manager
- **WeatherService**: API-Calls und Datenverarbeitung
- **LocationManager**: GPS und Standortverarbeitung
- **SettingsManager**: Benutzereinstellungen und Unit-Konvertierung

## Setup und Installation

### Voraussetzungen
- Xcode 15.0+
- iOS 18.0+
- Swift 5.9+

### API-Key einrichten
1. Registriere dich bei [WeatherAPI.com](https://www.weatherapi.com/)
2. Hole dir einen kostenlosen API-Key
3. Öffne `WeatherService.swift`
4. Ersetze `"YOUR_API_KEY_HERE"` mit deinem API-Key:
```swift
private let apiKey = "dein_echter_api_key_hier"
```

### Projekt öffnen
1. Öffne `WeatherApp.xcodeproj` in Xcode
2. Wähle dein Entwicklerteam in den Projekt-Einstellungen
3. Wähle ein iOS-Gerät oder Simulator
4. Drücke ⌘+R zum Ausführen

## Verwendete APIs

### WeatherAPI.com
- Current Weather: Aktuelle Wetterdaten
- Forecast: 7-Tage Vorhersage mit stündlichen Daten
- Search: Städtesuche für Standortauswahl
- Astronomy: Sonnen- und Mondzeiten

### Apple Frameworks
- **SwiftUI**: Deklarative UI
- **CoreLocation**: GPS und Geocoding
- **MapKit**: Kartenanzeige
- **Combine**: Reaktive Datenströme
- **Foundation**: Grundlegende Datentypen

## Projektstruktur

```
WeatherApp/
├── WeatherAppApp.swift          # App Entry Point
├── ContentView.swift            # Main Tab View
├── Models/
│   └── WeatherModel.swift       # Datenmodelle
├── Views/
│   ├── HomeView.swift           # Hauptansicht
│   ├── MapView.swift            # Kartenansicht
│   ├── ForecastView.swift       # Vorhersage
│   ├── DetailsView.swift        # Detailansicht
│   └── SettingsView.swift       # Einstellungen
├── Services/
│   └── WeatherService.swift     # API Service
├── Managers/
│   ├── LocationManager.swift    # Standortmanagement
│   └── SettingsManager.swift    # Einstellungsmanagement
├── Assets.xcassets/             # App Icons & Colors
└── Info.plist                  # App Konfiguration
```

## Features im Detail

### Einheiten-Konvertierung
- Temperatur: Celsius ↔ Fahrenheit
- Geschwindigkeit: km/h ↔ mph ↔ m/s
- Entfernung: km ↔ Meilen
- Luftdruck: mbar ↔ inHg ↔ hPa

### Dark Mode Support
- Automatische Dark Mode Erkennung
- Manueller Dark Mode Toggle
- Konsistente Farbschemata

### Standort-Features
- Automatische Standorterkennung
- Mehrere Standorte speichern
- Stadtesuche mit Autocomplete
- Koordinaten-basierte Wetterabfrage

### Responsive Design
- iPhone und iPad Support
- Verschiedene Bildschirmgrößen
- Portrait und Landscape Modi
- Adaptive UI-Komponenten

## Bekannte Einschränkungen

1. **API-Key erforderlich**: Die App benötigt einen gültigen WeatherAPI.com Key
2. **Internet-Verbindung**: Wetterdaten werden online abgerufen
3. **Standortberechtigung**: GPS muss aktiviert sein für automatische Standorterkennung

## Entwicklung und Debugging

### Debug-Modus
- Xcode Console zeigt API-Aufrufe und Fehler
- Location Updates werden geloggt
- Settings-Änderungen werden verfolgt

### Testen
- SwiftUI Previews für alle Views verfügbar
- Simulator-Tests für verschiedene Geräte
- Location-Simulation in Xcode


## Lizenz

Das Projekt ist frei nutzbar.

## Support

Bei Fragen oder Problemen:
1. Überprüfe die Xcode Console auf Fehlermeldungen
2. Stelle sicher, dass der API-Key korrekt eingetragen ist
3. Überprüfe die Internetverbindung
4. Aktiviere Standortdienste in den iOS-Einstellungen

---

**Entwickelt mit ❤️ für iOS 18**
