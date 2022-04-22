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
                CalendarTab().tabItem { Text("Connect your calendar") }
                GeneralTab().tabItem { Text("Settings") }
            }
        }.padding()
    }
}

struct PreferencesView_Previews: PreviewProvider{
    static var previews: some View{
        PreferencesView()
    }
}
