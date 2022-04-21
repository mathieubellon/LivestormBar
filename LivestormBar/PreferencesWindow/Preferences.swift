//
//  Preferences.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 20/04/2022.
//

import SwiftUI

struct PreferencesView: View {
    var body: some View {
        VStack {
            TabView {
                GeneralTab().tabItem { Text("General") }
                CalendarTab().tabItem { Text("Connect your calendar") }
            }
        }.padding()
    }
}

struct PreferencesView_Previews: PreviewProvider{
    static var previews: some View{
        PreferencesView()
    }
}
