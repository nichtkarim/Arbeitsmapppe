//
//  TrainIndicatorView.swift
//  teamhochbahn
//
//  Created by Team Hochbahn on 23.11.23.
//

import SwiftUI

/*
struct DepartureBoardView: View {
    @StateObject var query: HVVDepartureBoardVM
    
    @StateObject var settings = HVVSettings.shared
    
    var body: some View {
        ZStack{
            settings.colors(.Background).ignoresSafeArea()
            VStack{
                PageInformationComponent(information: "\(query.query.station.name) Gleis \(query.platformId)")
                    .accessibilityLabel("Abfahrten")
                    .accessibilityHint("Auflistung aller nächsten Abfahrten.")
                ScrollView {
                    ForEach(query.departures){departure in
                        DepartureCard(departure: departure)
                            .padding(5)
                    }
                }
            }
        }
        .navigationBarItems(trailing: FavoriteButton(query: query))
        .onDisappear(){
            // stop automatic refresh task
            query.cancel()
        }
    }
}
*/

struct DepartureBoardStickyView: View {
    @StateObject var viewModel: HVVDepartureBoardVM
    
    @StateObject var settings = HVVSettings.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack{
            settings.colors(.Background).ignoresSafeArea()
            VStack{
                if let query = viewModel.query{
                    let lineOrDirection = query.focusOnLine != nil ? ", Linie \(query.focusOnLine!.name) Richtung \(query.focusOnDirection!)" : "Gleis \(query.platformId)"
                    PageInformationComponent(information: "\(query.station.name) Gleis \(query.platformId)")
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Abfahrten \(query.station.name) Gleis \(query.platformId)")
                        .accessibilityHint("Auflistung aller nächsten Abfahrten. Du kannst hochscrollen für die nächste Abfahrt.")
                        .navigationBarItems(trailing:
                            FavoriteButton(isFavorite: $viewModel.isFavorite)
                                .accessibilityLabel(viewModel.isFavorite ? "Lösche von Favoriten" : "Speicher als Favorit")
                                .accessibilityHint(
                                    viewModel.isFavorite ? "Lösche Abfahrtstafel für Haltestelle \(query.station.name) \(lineOrDirection) von Favoriten" : "Speicher Abfahrtstafel für Haltestelle \(query.station.name) \(lineOrDirection) als Favorit")
                        )
                }
                SnappyDepartureScroll(viewModel: viewModel, activeIndex: 0)
                    .padding(.bottom)
                Spacer()
            }
        }
        .onDisappear(){ viewModel.onDisappear() }
        .onAppear(){ viewModel.onAppear() }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                viewModel.onDisappear()
            }
            else if phase == .active {
                viewModel.onAppear()
            }
        }
    }
}

struct SnappyDepartureScroll: View {
    @StateObject var viewModel: HVVDepartureBoardVM
    
    @State var activeIndex: Int
    @State var activeId: String = ""
    @State var offset: CGSize = .zero
    
    @StateObject var settings = HVVSettings.shared
    @AccessibilityFocusState var focusedDeparture: Departure?
    
    func stringRepresentationForDepartureIndex(index: Int) -> String {
        if index == 0 {
            return "Nächste Abfahrt"
        }
        else if index == 1 {
            return "Nach einer Abfahrt"
        }
        else {
            return "\(index+1). Abfahrt"
        }
    }
    
    @ViewBuilder
    func placeholder() -> some View {
        BorderedButtonComponent(
            borderColor: Color.clear,
            buttonLineWidthScale: 1.5
        ){
            VStack(alignment: .leading){
                Text("Dummy")
                    .font(size: .Small)
                    .opacity(0)
            }
            .padding([.leading, .trailing])
            .frame(minHeight: 50)
        }
    }
    
    var body: some View {        
        let dragGesture = DragGesture()
            .onChanged{ value in
                self.offset = value.translation
            }
            .onEnded{ value in
                var add = 0
                if value.translation.height > 80 && self.activeIndex > 0{
                    add -= 1
                }
                else if value.translation.height < 80 && self.activeIndex+1 < viewModel.departures.count {
                    add += 1
                }
                withAnimation(.interactiveSpring){
                    self.offset = .zero
                    self.activeIndex += add
                    self.viewModel.focusedDeparture = viewModel.departures[self.activeIndex]
                }
                
            }
        
        func heightForIndex(_ index: Int) -> Double {
            if index < self.activeIndex {
                return  -300
            }
            if index > self.activeIndex {
                return  300
            }
            if index == self.activeIndex {
                return (Double(self.offset.height)/5)
            }
            return 0
        }
        
        return VStack(alignment: .leading){
            if !self.viewModel.departures.isEmpty {
                /// show previous departure relative to selected
                if activeIndex > 0 {
                    BorderedButtonComponent(
                        borderColor: Color.blend(
                            color1: viewModel.departures[activeIndex-1].line.color,
                            color2: settings.colors(.Background)),
                        buttonLineWidthScale: 2
                    ){
                        VStack(alignment: .leading){
                            ZStack(alignment: .leading) {
                                ForEach(Array(viewModel.departures.enumerated()), id: \.element){ index, departure in
                                    HStack{
                                        Text("\(departure.line.name)")
                                        Text("\(departure.direction)")
                                    }
                                    .font(size: .Small)
                                    .opacity(index == activeIndex-1 ? 1 : 0)
                                }
                            }
                        }
                        .padding([.leading, .trailing])
                        .frame(minHeight: 50)
                    }
                    .gesture(TapGesture().onEnded{
                        withAnimation(.spring){
                            if activeIndex > 0 {
                                self.activeIndex -= 1
                                self.viewModel.focusedDeparture = viewModel.departures[self.activeIndex]
                            }
                        }
                    })
                } else {
                    // placeholder to avoid to much movement in the view
                    placeholder()
                }
                
                /// show details for selected departure
                    BorderedButtonComponent(
                        borderColor: viewModel.departures[activeIndex].line.color,
                        buttonLineWidthScale: 3
                    ){
                        VStack(alignment: .center){
                            /// show amount of departures till selected departure
                            VStack(alignment: .leading){
                                Text(stringRepresentationForDepartureIndex(index: activeIndex))
                            }
                            .font(size: .Small)
                            Rectangle()
                                .frame(height: 2)
                            ZStack(alignment: .leading) {
                                ForEach(Array(viewModel.departures.enumerated()), id: \.element){ index, departure in
                                    VStack(alignment: .leading){
                                        VStack{
                                            Spacer()
                                            VStack(alignment:.leading){
                                                Text("\(departure.line.name)")
                                                Text("\(departure.direction)")
                                                /*if departure.notes != nil {
                                                    ForEach(departure.notes!){ note in
                                                        Text("\(note.type.rawValue)")
                                                    }
                                                }*/
                                            }
                                            .offset(CGSize(width: 0, height: heightForIndex(index)))
                                            Spacer()
                                        }
                                        .clipped()
                                        Rectangle()
                                            .frame(height: 2)
                                        Text("\(departure.timeTillDeparture)")
                                    }
                                    .opacity(index == activeIndex ? 1 : 0)
                                }
                            }
                            
                        }
                        .padding([.leading, .trailing])
                    }.onTapGesture{
                        HVVNavigationStack.shared.pushRoute(Route.departureBoardDetails(viewModel.departures[activeIndex]))
                    }
                    .font(size: .Normal)
                    
                /// show next departure relative to selected
                if self.activeIndex+1 < viewModel.departures.count  {
                    BorderedButtonComponent(
                        borderColor: Color.blend(
                            color1: viewModel.departures[activeIndex+1].line.color,
                            color2: settings.colors(.Background)),
                        buttonLineWidthScale: 2
                    ){
                        VStack(alignment: .leading){
                            ZStack(alignment: .leading) {
                                ForEach(Array(viewModel.departures.enumerated()), id: \.element){ index, departure in
                                    HStack{
                                        Text("\(departure.line.name)")
                                        Text("\(departure.direction)")
                                    }
                                    .font(size: .Small)
                                    .opacity(index == activeIndex+1 ? 1 : 0)
                                }
                            }
                        }
                        .padding([.leading, .trailing])
                        .frame(minHeight: 50)
                    }
                    .gesture(TapGesture().onEnded{
                        withAnimation(.spring){
                            if activeIndex < viewModel.departures.count-1 {
                                self.activeIndex += 1
                                self.viewModel.focusedDeparture = viewModel.departures[self.activeIndex]
                            }
                        }
                    })
                } else {
                    // placeholder to avoid to much movement in the view
                    placeholder()
                }
            }
        }
        .gesture(dragGesture)
        .foregroundStyle(settings.colors(.Primary))
        .onAppear {
            if !viewModel.departures.isEmpty {
                withAnimation(.spring){
                    self.activeIndex = viewModel.departures.firstIndex(where: {$0.line == viewModel.query?.focusOnLine && $0.direction == viewModel.query?.focusOnDirection}) ?? 0
                }
            }
        }
        .onChange(of: viewModel.departures) {
            withAnimation(.spring){
                self.activeIndex = self.viewModel.focusedDeparture != nil ? (viewModel.departures.firstIndex(of: viewModel.focusedDeparture!) ?? 0) : (viewModel.departures.firstIndex(where: {$0.line == viewModel.query?.focusOnLine && $0.direction == viewModel.query?.focusOnDirection}) ?? 0)
            }
        }
        .accessibilityChildren {
            GeometryReader{geo in
                List(Array(viewModel.departures.enumerated()), id: \.element){ index, departure in
                    Rectangle()
                        .frame(height: geo.size.height / (Double(viewModel.departures.count)+2))
                        .accessibilityLabel("\(stringRepresentationForDepartureIndex(index: index)), \(departure.line.name) Richtung \(departure.direction). Abfahrt \(departure.timeTillDeparture). Klicke, um dich über den Fahrtverlauf zu informieren.")
                        .accessibilityFocused($focusedDeparture, equals: departure)
                        .accessibilityAction {
                            HVVNavigationStack.shared.pushRoute(Route.departureBoardDetails(departure))
                        }
                }
            }
        }
        .onChange(of: focusedDeparture) {
            if let focusedDeparture = focusedDeparture {
                self.viewModel.focusedDeparture = focusedDeparture
                self.activeIndex = viewModel.departures.firstIndex(of: focusedDeparture) ?? 0
            }
        }
    }
    
}

