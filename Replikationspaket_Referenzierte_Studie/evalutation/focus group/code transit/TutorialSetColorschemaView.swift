//
//  TutorialSetColorschema.swift
//  teamhochbahn
//
//  Created by Team Hochbahn on 01.12.23.
//

import SwiftUI

struct TutorialSetColorschemaView: View {
    
    @StateObject var settings = HVVSettings.shared
    @StateObject var state = AppStateStorage.shared
    
    var body: some View {
        ZStack{
            settings.colors(.Background).ignoresSafeArea()
            VStack{
                PageInformationComponent(information: "Farbschema")
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                SetColorSchemaViewPlain()
                Spacer()
                Button(action: {
                    state.changeTo(state: .Default)
                }){
                    HStack{
                        Text("Zur App")
                        Image(systemName: "arrow.right")
                            .bold()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(30)
                    .accessibilityElement()
                    .accessibilityLabel("Zur App")
                    .accessibilityHint("Mit der Nutzung der App starten")
                }
                .font(size: .Normal)
                .foregroundStyle(settings.colors(.Primary))
                .background {
                    TutorialButtonBackground()
                }
            }
        }
    }
}
    


#Preview {
    TutorialSetColorschemaView()
        .withNavigationStack()
}
