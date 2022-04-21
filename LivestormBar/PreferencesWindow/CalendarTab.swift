//
//  CalendarTab.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 20/04/2022.
//


import SwiftUI



struct CalendarTab: View {
    

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            Divider()
            yourCalendar()

        }.padding()
    }
}

struct yourCalendar: View {
    @State var showingModal = false

    var body: some View {
        HStack {
            Text("Vos calendriers")


            Text("preferences_general_shortcut_join_next")
          

            Spacer()

            Button(action: { self.showingModal.toggle() }) {
                Text("preferences_general_all_shortcut")
            }.sheet(isPresented: $showingModal) {
                Text("modal___")
            }
        }
    }
}


struct yourCalendar_Previews: PreviewProvider{
    static var previews: some View{
        PreferencesView()
    }
}
