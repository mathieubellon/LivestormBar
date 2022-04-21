//
//  CalendarTab.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 20/04/2022.
//


import SwiftUI



struct CalendarTab: View {
    
    init(){
        print("Open calendar tab")
        
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            
            yourCalendar()
            Spacer()

        }.padding()
    }
}

struct yourCalendar: View {
    @State var showingModal = false
    
    


    var body: some View {
        HStack {
            Text("Vos calendriers")


            Text("preferences_general_shortcut_join_next")
            
            
            
            Button("Disconnect") {
                forgetTokens()
            }

            Spacer()
            

//            Button(action: { self.showingModal.toggle() }) {
//                Text("Disconnect")
//            }.sheet(isPresented: $showingModal) {
//                Text("Are you sure")
//            }
        }
    }
}


struct yourCalendar_Previews: PreviewProvider{
    static var previews: some View{
        PreferencesView()
    }
}

func forgetTokens() {
    NSLog("Deleting token")
    loader.oauth2.forgetTokens()
}
