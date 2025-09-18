//
//  HomepageView.swift
//  teamhochbahn
//
//  Created by Team Hochbahn on 15.11.23.
//

import SwiftUI
import CoreLocation

struct HomepageView: View {
    
    @StateObject var settings = HVVSettings.shared
    
    var body: some View {
        ZStack{
            settings.colors(.Background).ignoresSafeArea()
            VStack{
                Text("Moin")
                    .font(size: .ExtraLarge)
                    .foregroundColor(settings.colors(.Primary))
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .padding()
                    .padding(.leading, 25)
                    .accessibilityAddTraits(.isHeader)
                    .background(
                        Rectangle()
                            .fill(settings.colors(.SecondaryBackground))
                            .cornerRadius(25, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                    )
                ScrollView{
                    NavigationLink(value: Route.selectLine(HVVSearchDepartureBoardVM.QueryBuilder())){
                        HomepageButton(home: "Suche", icon:"magnifyingglass")
                    }
                    .accessibilityLabel("Suche")
                    .accessibilityHint("Suche eine Abfahrtstafel und informiere dich über die nächsten Abfahrten an einem Gleis")
                    
                    NavigationLink(value: Route.favorites){
                        HomepageButton(home: "Favoriten", icon:"heart.fill")
                    }
                    .accessibilityLabel("Favoriten")
                    .accessibilityHint("Nutze favorisierte Abfahrtstafeln, um dich schnell über die nächsten Abfahrten zu informieren")
                    
                    NavigationLink(value: Route.settings){
                        HomepageButton(home: "Einstellungen", icon:"gear")
                    }
                    .accessibilityLabel("Einstellungen")
                    .accessibilityHint("Individualisiere die App nach deinen Bedürfnissen")
                }
            }
        }
    }
}
    


#Preview {
    HomepageView()
        .withNavigationStack()
}

