//
//  SearchStartView.swift
//  teamhochbahn
//
//  Created by Team Hochbahn on 18.11.23.
//

import SwiftUI
import CoreLocation

struct HVVDivider: View {
    @StateObject var settings = HVVSettings.shared
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundStyle(settings.colors(.Primary))
            .padding()
    }
}

struct StationSelectionButtonComponent: View {
    @StateObject var vm: HVVSearchDepartureBoardVM
    
    var body: some View {
        NavigationLink(value: Route.searchStation(HVVSearchStationVM())){
            switch vm.selectedStation {
            case .fromSearch(let station):
                BorderedButtonComponent(textAlignment: .leading) {
                    VStack(alignment: .leading){
                        Text("Start-Haltestelle")
                            .font(size: .Small)
                        Text(station.name)
                            .font(size: .Large)
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("Starthaltestelle")
                .accessibilityValue(station.name)
                .accessibilityHint("Klicke, um deine Starthaltestelle zu ändern")
            case .fromLocation(let locator):
                NearestStationButtonComponent(locator: locator, label: "Start-Haltestelle")
                    .accessibilityLabel("Starthaltestelle")
            }
        }

    }
}

struct NearestStationButtonComponent: View {
    @StateObject var locator: HVVNearestStationLocatorVM
    
    var label: String = "Dein Standort"
    
    var body: some View {
        if let station = locator.nearestStation, !locator.isRelocating {
            BorderedButtonComponent(textAlignment: .leading) {
                VStack(alignment: .leading){
                    Label(label, systemImage: "location")
                        .font(size: .Small)
                    Text(station.name)
                        .font(size: .Large)
                }
            }
            .accessibilityElement()
            .accessibilityValue("\(station.name), die von dir am nächstliegende Haltestelle")
                //.accessibilityHint("Du kannst deinen Standort wechseln.") // dafür müsste man erstmal ein Stückchen laufen
        } else if let error = locator.error as? HVVNearestStationLocatorVM.HVVError {
            switch error {
            case .NoStationNearby:
                BorderedButtonComponent(textAlignment: .leading) {
                    VStack(alignment: .leading){
                        Text("Keine Haltestelle in der Nähe")
                            .font(size: .Normal)
                    }
                }
                .accessibilityElement()
                .accessibilityValue("Keine Haltestelle in der Nähe")
                .accessibilityHint("Es wurde keine Station in der Nähe gefunden")
            case .PermissionDenied:
                BorderedButtonComponent(textAlignment: .leading) {
                    VStack(alignment: .leading){
                        Text("Keine Standortfreigabe")
                            .font(size: .Normal)
                    }
                }
                .accessibilityElement()
                .accessibilityValue("Keine Standortfreigabe")
                .accessibilityHint("Erlaube der App den Zugriff auf deine Standort, um die nähstliegende Station zu ermitteln")
            }
        } else {
            BorderedButtonComponent(textAlignment: .leading) {
                VStack(alignment: .leading){
                    Label(label, systemImage: "location")
                        .font(size: .Small)
                    Text("sucht...")
                        .font(size: .Large)
                }
            }
            .accessibilityElement()
            .accessibilityValue("Nächstliegende Station wird gesucht.")
            .accessibilityHint("Du kannst deinen Standort wechseln.")
        }
    }
}

struct SelectLineView: View {
    let selection: HVVSearchDepartureBoardVM.QueryBuilder
    
    @StateObject var stationSel: HVVSearchDepartureBoardVM = HVVSearchDepartureBoardVM.shared
    @StateObject var settings = HVVSettings.shared
    
    var body: some View {
        ZStack{
            settings.colors(.Background).ignoresSafeArea()
            VStack{
                PageInformationComponent(information: "Wähle Starthaltestelle mit Linie oder Gleis")
                    .accessibilityAddTraits(.isHeader)
                ScrollView{
                    StationSelectionButtonComponent(vm: stationSel)
                    HVVDivider()
                    if let station = stationSel.station {
                        ForEach(station.linesAtStop, id: \.name){line in
                            NavigationLink(value: Route.selectDirection(selection.setLine(line: line))){
                                TrainButton(line: line.name, lineColor: line.color)
                                    .accessibilityLabel("Abfahrten der Linie \(line.name)")
                            }
                        }
                        NavigationLink(value: Route.selectPlatform(selection)){
                            BorderedButtonComponent(alignment: .center) {
                                Text("Gleis wählen")
                            }
                            .accessibilityLabel("Gleis wählen")
                            .accessibilityHint("Zeigt alle Gleisen der U-Bahn Station")
                        }
                        NavigationLink(value: Route.detectPlatform(selection)){
                            BorderedButtonComponent(alignment: .leading, textAlignment: .leading) {
                                Label("Gleis scannen", systemImage: "binoculars.fill")
                            }
                            .accessibilityLabel("Gleis Scannen")
                            .accessibilityHint("Scanne die Gleise, um die Abfahrten anzuzeigen.")
                        }
                    }
                }
                .refreshable {
                    stationSel.refresh()
                }
            }
        }
    }
}


#Preview {
    SelectLineView(selection: .init())
        .withNavigationStack()
}
