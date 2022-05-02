//
//  GeneralTab.swift
//  MeetingBar
//
//  Created by Andrii Leitsius on 13.01.2021.
//  Copyright © 2021 Andrii Leitsius. All rights reserved.
//

import SwiftUI
import Defaults
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let openNextEvent = Self("openNextEvent")
}



struct SettingsTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
            ShortcutsSection()
            Spacer()
            Divider()
            Spacer()
            NotificationsSection()
            Spacer()
            Divider()
            Spacer()
            CreditsSection()
        }.padding()

    }
}



struct NotificationsSection: View{
    
    @Default(.userWantsNotificationsAtEventStart) var userWantsNotificationsAtEventStart
    @Default(.userWantsNotifications1mnBeforeEventStart) var userWantsNotifications1mnBeforeEventStart
    @Default(.userWantsNotifications5mnBeforeEventStart) var userWantsNotifications5mnBeforeEventStart
    @Default(.userWantsNotifications10mnBeforeEventStart) var userWantsNotifications10mnBeforeEventStart
    
    var body: some View{
        
        VStack(alignment: .leading) {
            Text("Notifications").fontWeight(.bold).lineSpacing(10.0)
            Toggle("Envoyer une notification au début de la réunion", isOn:
                     $userWantsNotificationsAtEventStart)
            Toggle("Envoyer une notification 1mn avant le début de la réunion", isOn: $userWantsNotifications1mnBeforeEventStart)
            Toggle("Envoyer une notification 5mn avant le début de la réunion", isOn: $userWantsNotifications5mnBeforeEventStart)
            Toggle("Envoyer une notification 10mn avant le début de la réunion", isOn: $userWantsNotifications10mnBeforeEventStart)
        }
    }
    
}


struct ShortcutsSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Keyboard shortcuts").fontWeight(.bold).lineSpacing(10.0)
            Form {
                KeyboardShortcuts.Recorder("Open next event (in Livestorm if link available or Google Calendar):", name: .openNextEvent)
            }
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
        }
    }
}


struct GeneralTab_Previews: PreviewProvider{
    static var previews: some View{
        SettingsTab()
    }
}
