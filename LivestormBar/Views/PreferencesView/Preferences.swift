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
                SettingsTab().tabItem { Text("settings") }
                CalendarTab().tabItem { Text("connect_your_calendar") }
            }
        }.padding()
    }
}

struct PreferencesView_Previews: PreviewProvider{
    static var previews: some View{
        PreferencesView()
    }
}
