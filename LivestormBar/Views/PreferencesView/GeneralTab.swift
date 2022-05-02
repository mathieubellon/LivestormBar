//
//  GeneralTab.swift
//  MeetingBar
//
//  Created by Andrii Leitsius on 13.01.2021.
//  Copyright © 2021 Andrii Leitsius. All rights reserved.
//

import SwiftUI
import Defaults


struct GeneralTab: View {


    var body: some View {
        VStack(alignment: .leading, spacing: 30) {            
            Divider()
            NotificationsSection()
            Divider()
            CreditsSection()
            Spacer()
        }.padding()

    }
}

struct NotificationsSection: View{
    
    @Default(.userWantsNotifications) var userWantsNotifications
    
    var body: some View{
        HStack {
            Toggle("Envoyer une notification une minute avant le début de la réunion", isOn: $userWantsNotifications)
        }
    }
    
}

struct CreditsSection: View{
    var body: some View{
        HStack {
            VStack(alignment: .center) {
                Image(nsImage: NSImage(named: "AppIcon")!).resizable().frame(width: 100.0, height: 100.0)
                Text("LivestormBar").font(.system(size: 20)).bold()
                if Bundle.main.infoDictionary != nil {
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")").foregroundColor(.gray)
                }
            }.lineLimit(1).minimumScaleFactor(0.5).frame(minWidth: 0, maxWidth: .infinity)
//            VStack {
//                Spacer()
//                Text("preferences_general_meeting_bar_description").multilineTextAlignment(.center)
//                Spacer()
//
//                HStack {
//                    Spacer()
////                    Button(action: clickPatronage) {
////                        Text("preferences_general_external_patronage".loco())
////                    }.sheet(isPresented: $showingPatronageModal) {
////                        PatronageModal()
////                    }
//                    Spacer()
//                    Button(action: { }) {
//                        Text("preferences_general_external_gitHub")
//                    }
//                    Spacer()
//           
//                    Spacer()
//                }
//                Spacer()
//            }.frame(minWidth: 360, maxWidth: .infinity)
        }
    }
}


struct GeneralTab_Previews: PreviewProvider{
    static var previews: some View{
        GeneralTab()
    }
}
