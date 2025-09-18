//
//  SearchStationView.swift
//  hvvvision
//
//  Created by Team Hochbahn on 02.12.23.
//

import SwiftUI

struct SearchStationView: View {
    @StateObject var stationSearch: HVVSearchStationVM
    @StateObject var settings = HVVSettings.shared
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @FocusState var isSearchFocused: Bool
    
    var searchfieldBackground: Color { get {
            Color.blend(color1: settings.colors(.Background), intensity1: 0.9, color2: settings.colors(.Primary), intensity2: 0.1)
        }}
    var searchfieldPlaceholder: Color { get {
            Color.blend(color1: settings.colors(.Background), intensity1: 0.3, color2: settings.colors(.Primary), intensity2: 0.7)
        }}
    
    var body: some View {
        ZStack {
            settings.colors(.Background).ignoresSafeArea()
            VStack{
                PageInformationComponent(information: "Start Haltestelle ändern")
                    .accessibilityAddTraits(.isHeader)
                BorderedButtonComponent(backgroundColor: searchfieldBackground){
                    TextField("", text: $stationSearch.queryString)
                        .onSubmit {
                            stationSearch.update()
                        }
                        .placeholder(when: stationSearch.queryString.isEmpty){
                            Label("Suchen", systemImage: "magnifyingglass")
                                .font(size: .Normal)
                                .foregroundStyle(searchfieldPlaceholder)
                        }
                        .focused($isSearchFocused)
                        .accessibilityAddTraits(.isSearchField)
                        .accessibilityLabel("Start Haltestelle Suchen")
                        .accessibilityHint("Gib deine Start Haltestelle ein, klicke auf Enter und wähle eine Haltestelle in der unten stehenden Liste.")
                }
                HVVDivider()
                List{
                    if stationSearch.queryString == "" {
                        Button(action: {
                            stationSearch.selectStationFromLocation()
                            presentationMode.wrappedValue.dismiss()
                        }){
                            NearestStationButtonComponent(locator: HVVNearestStationLocatorVM.shared)
                                .accessibilityLabel("Wähle")
                        }
                        .listRowBackground(settings.colors(.Background))
                        .listRowInsets(EdgeInsets())
                    }
                    ForEach(stationSearch.results, id: \.self){ station in
                        BorderedButtonComponent(){
                            Button(action: {
                                stationSearch.selectStation(station: station)
                                presentationMode.wrappedValue.dismiss()
                            }){
                                Text("\(station.name)")
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(settings.colors(.Primary))
                                    .padding()
                            }
                        }
                        .accessibilityLabel("\(station.name)")
                        .accessibilityHint("Wähle \(station.name) als deine Starthaltestelle.")
                        .listRowBackground(settings.colors(.Background))
                        .listRowInsets(EdgeInsets())
                        .padding(.bottom)
                    }
                }
                .listStyle(.plain)
            }
            .font(size: .Large)
            .foregroundStyle(settings.colors(.Primary))
        }
        .onAppear {
            HVVNearestStationLocatorVM.shared.update()
            isSearchFocused = true
        }
    }
}

#Preview {
    SearchStationView(stationSearch: .init())
}
