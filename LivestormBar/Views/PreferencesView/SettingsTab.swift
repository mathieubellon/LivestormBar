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
import Sparkle
import LaunchAtLogin
import UserNotifications

extension KeyboardShortcuts.Name {
    static let openNextEvent = Self("openNextEvent")
}


// This view model class manages Sparkle's updater and publishes when new updates are allowed to be checked
final class UpdaterViewModel: ObservableObject {
    private let updaterController: SPUStandardUpdaterController
    
    @Published var canCheckForUpdates = false
    
    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
    
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}

struct SettingsTab: View {
    @StateObject var updaterViewModel = UpdaterViewModel()
    var body: some View {
        VStack(alignment: .leading) {
            ShortcutsSection()
            Spacer()
            NotificationsSection()
            Spacer()
            LaunchAtLoginSection()
            Spacer()
            CreditsSection(updaterViewModel: updaterViewModel)
          
        }.padding()
        
    }
}

struct LaunchAtLoginSection: View{
    var body: some View{
        VStack(alignment: .leading){
            Text("Startup").fontWeight(.bold).lineSpacing(10.0)
            LaunchAtLogin.Toggle {
                Text("Launch Livestormbar at login")
            }
            
        }
    }
}

struct NotificationsSection: View{
    
    @Default(.userWantsNotificationsAtEventStart) var userWantsNotificationsAtEventStart
    @Default(.userWantsNotifications1mnBeforeEventStart) var userWantsNotifications1mnBeforeEventStart
    @Default(.userWantsNotifications5mnBeforeEventStart) var userWantsNotifications5mnBeforeEventStart
    @Default(.userWantsNotifications10mnBeforeEventStart) var userWantsNotifications10mnBeforeEventStart
    
    func checkNotificationSettings() -> (Bool, Bool) {
        var noAlertStyle = false
        var notificationsDisabled = false

        let center = UNUserNotificationCenter.current()
        let group = DispatchGroup()
        group.enter()

        center.getNotificationSettings { notificationSettings in
            noAlertStyle = notificationSettings.alertStyle != UNAlertStyle.alert
            notificationsDisabled = notificationSettings.authorizationStatus == UNAuthorizationStatus.denied
            group.leave()
        }

        group.wait()
        return (noAlertStyle, notificationsDisabled)
    }
    
    var body: some View{
  
        VStack(alignment: .leading) {
        
            
            
            let (noAlertStyle, disabled) = checkNotificationSettings()

            if noAlertStyle && !disabled {
                Text("Notifications non persistantes").fontWeight(.semibold).lineSpacing(10.0)
                HStack (alignment: .top){
                    Text("Si vous choisissez les notifications de type \"Alertes\" elles seront persistantes").foregroundColor(Color.gray).font(.system(size: 12))
                    
                    Button("Modifier"){
                        preferencesWindow.close()
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Notifications.prefPane"))
                    }.buttonStyle(.plain).foregroundColor(Color.blue).font(.system(size: 12))
                }
            } else if disabled {
                Text("Notifications impossible").fontWeight(.semibold).lineSpacing(10.0).foregroundColor(Color.red)
                HStack(alignment: .top){
                    Text("Vous n'avez pas autorisé LivestormBar à vous envoyer des  notifications").foregroundColor(Color.red).font(.system(size: 12))
                    Button("Modifier"){
                        preferencesWindow.close()
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Notifications.prefPane"))
                    }.buttonStyle(.plain).foregroundColor(Color.blue).font(.system(size: 12))
                }
            } else{
                Text("Notifications").fontWeight(.bold).lineSpacing(10.0)
            }
            
            
            Toggle("Envoyer une notification au début de la réunion", isOn:
                    $userWantsNotificationsAtEventStart).disabled(disabled)
            Toggle("Envoyer une notification 1mn avant le début de la réunion", isOn: $userWantsNotifications1mnBeforeEventStart).disabled(disabled)
            Toggle("Envoyer une notification 5mn avant le début de la réunion", isOn: $userWantsNotifications5mnBeforeEventStart).disabled(disabled)
            Toggle("Envoyer une notification 10mn avant le début de la réunion", isOn: $userWantsNotifications10mnBeforeEventStart).disabled(disabled)
         
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
    @ObservedObject var updaterViewModel: UpdaterViewModel
    @State private var isPresentingConfirm: Bool = false
    var body: some View{
        Divider()
        Spacer()
        HStack(spacing: 2.0) {

            VStack(alignment: .center) {
                Image(nsImage: NSImage(named: "AppIcon")!).resizable().frame(width: 100.0, height: 100.0)
                Text("LivestormBar").font(.system(size: 20)).bold()
                if Bundle.main.infoDictionary != nil {
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")").foregroundColor(.gray)
                }
                
            }.lineLimit(1).minimumScaleFactor(0.5).frame(minWidth: 0)
            VStack{
                Button("Check for Updates…", action: updaterViewModel.checkForUpdates)
                    .disabled(!updaterViewModel.canCheckForUpdates)
                //Button("print defaults", action:printUserDefaults)
                Button("Reset to factory defaults", role: .destructive) {
                    isPresentingConfirm = true
                }
                .confirmationDialog("Are you sure?",
                                    isPresented: $isPresentingConfirm) {
                    Button("Yes, delete", role: .destructive) {
                        resetFactoryDefault()
                    }
                }
            }.lineLimit(1).minimumScaleFactor(0.5).frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}


struct GeneralTab_Previews: PreviewProvider{
    static var previews: some View{
        SettingsTab()
            .frame(width: 600.0, height: 500.0)
    }
}
