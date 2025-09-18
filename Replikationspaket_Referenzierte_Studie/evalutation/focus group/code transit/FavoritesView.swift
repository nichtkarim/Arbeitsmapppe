//
//  FavoritesView.swift
//  teamhochbahn
//
//  Created by Team Hochbahn on 30.11.23.
//


import SwiftUI


struct FavoritesView: View {
    @StateObject var favorites: HVVFavorites = HVVFavorites.shared
    
    @StateObject var settings = HVVSettings.shared
    
    var body: some View {
        ZStack{
            settings.colors(.Background).ignoresSafeArea()
            VStack{
                PageInformationComponent(information: "Favoriten")
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHint("Wähle deinen favorisierte Linie aus.")
                List{
                    ForEach(favorites.favorites.sorted()){favorite in
                        NavigationLink(value: Route.departureBoard(.init(query: favorite.query))){
                            FavoriteCard(favorite: favorite)
                        }
                        .listRowBackground(settings.colors(.Background))
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -20))
                        
                    }
                    .onMove(perform: { indices, newOffset in
                        var current = favorites.favorites.sorted()
                        current.move(fromOffsets: indices, toOffset: newOffset)
                        for var (i, fav) in current.enumerated() {
                            fav.clickNumber = i
                        }
                    })
                }
                .listStyle(.plain)
                
            }
        }
    }
    
}

#Preview {
    FavoritesView()
        .withNavigationStack()
}


