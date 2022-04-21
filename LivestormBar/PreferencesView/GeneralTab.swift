//
//  GeneralTab.swift
//  MeetingBar
//
//  Created by Andrii Leitsius on 13.01.2021.
//  Copyright © 2021 Andrii Leitsius. All rights reserved.
//

import SwiftUI



struct GeneralTab: View {


    var body: some View {
        VStack(alignment: .leading, spacing: 30) {

            Label("Tous les calendriers", systemImage: "42.circle")
            
            Divider()
            ShortcutsSection()
            CreditsSection()
            Spacer()
        }.padding()

    }
}

struct ShortcutsSection: View {
    @State var showingModal = false

    var body: some View {
        HStack {
            Text("preferences_general_shortcut_create_meeting")


            Text("preferences_general_shortcut_join_next")
          

            Spacer()

            Button(action: { self.showingModal.toggle() }) {
                Text("preferences_general_all_shortcut")
            }.sheet(isPresented: $showingModal) {
                
            }
        }
    }
}

struct CreditsSection: View{
    var body: some View{
        HStack {
            VStack(alignment: .center) {
                Image(nsImage: NSImage(named: "AppIcon")!).resizable().frame(width: 120.0, height: 120.0)
                Text("LivestormBar").font(.system(size: 20)).bold()
                if Bundle.main.infoDictionary != nil {
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")").foregroundColor(.gray)
                }
            }.lineLimit(1).minimumScaleFactor(0.5).frame(minWidth: 0, maxWidth: .infinity)
            VStack {
                Spacer()
                Text("preferences_general_meeting_bar_description").multilineTextAlignment(.center)
                Spacer()

                HStack {
                    Spacer()
//                    Button(action: clickPatronage) {
//                        Text("preferences_general_external_patronage".loco())
//                    }.sheet(isPresented: $showingPatronageModal) {
//                        PatronageModal()
//                    }
                    Spacer()
                    Button(action: { }) {
                        Text("preferences_general_external_gitHub")
                    }
                    Spacer()
           
                    Spacer()
                }
                Spacer()
            }.frame(minWidth: 360, maxWidth: .infinity)
        }
    }
}


struct GeneralTab_Previews: PreviewProvider{
    static var previews: some View{
        GeneralTab()
    }
}
