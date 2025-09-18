//
//  TutorialSetFontsize.swift
//  teamhochbahn
//
//  Created by Team Hochbahn on 01.12.23.
//

import SwiftUI

struct TutorialSetFontsizeView: View {
    
    @StateObject var settings = HVVSettings.shared
    
    
    var body: some View {
        ZStack{
            settings.colors(.Background).ignoresSafeArea()
            VStack{
                PageInformationComponent(information: "Schriftgröße")
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                SetFontSizeViewPlain()
                Spacer()
                NavigationLink(value: Route.tutorialSetColorschema){
                    HStack{
                        Text("Weiter")
                        Image(systemName: "arrow.right")
                            .bold()
                    }
                    .padding(40)
                    .font(size: .Normal)
                    .foregroundStyle(settings.colors(.Primary))
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
                    .accessibilityElement()
                    .accessibilityLabel("Weiter")
                    .accessibilityHint("Gehe zum nächsten Schritt des Tutorials")
                    .accessibilityAddTraits(.isButton)
                    .background {
                        TutorialButtonBackground()
                    }
                }
                
            }
        }
    }
    
}

#Preview {
    TutorialSetFontsizeView()
        .withNavigationStack()
}
