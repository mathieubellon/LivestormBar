//
//  AppDelegate.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import Cocoa
import SwiftUI
import OAuth2
import Defaults
import UserNotifications
import KeyboardShortcuts


var preferencesWindow: NSWindow! = nil
var noteTakingWindow: NSWindow! = nil
let OAuth2AppDidReceiveCallbackNotification = NSNotification.Name(rawValue: "OAuth2AppDidReceiveCallback")

let loader = GoogleLoader()

let em = evenManager()

var statusBarItem: StatusBarItemController!
var isPreferencesWindowOpened = false


@main
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem = StatusBarItemController()
        statusBarItem.setAppDelegate(appdelegate: self)
        
        loader.oauth2.authConfig.authorizeContext = self
        NotificationCenter.default.removeObserver(self, name: OAuth2AppDidReceiveCallbackNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRedirect(_:)), name: OAuth2AppDidReceiveCallbackNotification, object: nil)
        
        _ = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.updateEvents), userInfo: nil, repeats: true)
        
        registerNotificationCategories()
        UNUserNotificationCenter.current().delegate = self
        
        self.updateEvents()
        
        KeyboardShortcuts.onKeyUp(for: .openNextEvent) { [self] in
            openNextEvent()
        }
    }
    
    
    internal func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "JOIN_ACTION", UNNotificationDefaultActionIdentifier:
            if response.notification.request.content.categoryIdentifier == "EVENT" {
                if response.notification.request.content.userInfo["extractedLink"] as? String != ""{
                    NSLog("Join \(response.notification.request.content.userInfo["extractedLink"]!) from notication")
                    openEventInDefaultBrowser(response.notification.request.content.userInfo["extractedLink"] as! String)
                }else{
                    openEventInDefaultBrowser(response.notification.request.content.userInfo["htmlLink"] as! String)
                }
            }
        default:
            break
        }

        completionHandler()
    }
    
    func openEventInDefaultBrowser(_ linkToOpen:String){
        NSWorkspace.shared.open(URL(string: linkToOpen)!)
    }
    
    @objc
    func updateEvents() {
        NSLog("Firing updateEvents")
        if Defaults[.email] != nil {
            NSLog("Do fetch events")
            em.fetchEvents()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func openNextEvent () {
        let now = Date()
        for event in em.eventsArray {
            if now < event.start!.dateTime!  || (event.start!.dateTime! < now && now < event.end!.dateTime!) {
                print(event.extractedLink!)
                if event.extractedLink! != "" {
                    NSWorkspace.shared.open(URL(string: event.extractedLink!)!)
                }else{
                    NSWorkspace.shared.open(URL(string: event.htmlLink!)!)
                }
                return
            }
        }
    }
    
    
    
    // register our app to get notified when launched via URL
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleURLEvent(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    /** Gets called when the App launches/opens via URL. */
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue {
            if let url = URL(string: urlString), "ppoauthapp" == url.scheme && "oauth" == url.host {
                NotificationCenter.default.post(name: OAuth2AppDidReceiveCallbackNotification, object: url)
            }
        }
        else {
            NSLog("No valid URL to handle")
        }
    }
    
    @objc func handleRedirect(_ notification: Notification) {
        if let url = notification.object as? URL {
            NSLog("Handling redirect...")
            do {
                try loader.oauth2.handleRedirectURL(url)
            }
            catch let error {
                NSLog("handleRedirect: \(error)")
            }
        }
        else {
            NSLog("ici une erreur")
            //show(NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid notification: did not contain a URL"]))
        }
    }

    
    @objc
    func openPreferencesWindow() {
        NSLog("Open preferences window")
        let contentView = PreferencesView()
        if preferencesWindow != nil {
            preferencesWindow.close()
        }
        preferencesWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 610),
            styleMask: [.closable, .titled, .resizable],
            backing: .buffered,
            defer: false
        )

        preferencesWindow.title = "Settings"
        preferencesWindow.contentView = NSHostingView(rootView: contentView)
        preferencesWindow.makeKeyAndOrderFront(nil)
        // allow the preference window can be focused automatically when opened
        NSApplication.shared.activate(ignoringOtherApps: true)

        let controller = NSWindowController(window: preferencesWindow)
        controller.showWindow(self)

        preferencesWindow.center()
        preferencesWindow.orderFrontRegardless()
    }
    
    @objc
    func openNoteTakingWindow(_ sender: NSMenuItem) {
        NSLog("Open preferences window")
        let contentView = NoteTakingView()
        if noteTakingWindow != nil {
            noteTakingWindow.close()
        }
        noteTakingWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 610),
            styleMask: [.closable, .titled, .resizable],
            backing: .buffered,
            defer: false
        )
        let event = sender.representedObject as? CalendarItem
        noteTakingWindow.title = "Notes for \(event?.summary ?? "")"
        noteTakingWindow.backgroundColor = .white
        noteTakingWindow.contentView = NSHostingView(rootView: contentView)
        noteTakingWindow.makeKeyAndOrderFront(nil)
        // allow the preference window can be focused automatically when opened
        NSApplication.shared.activate(ignoringOtherApps: true)

        let controller = NSWindowController(window: noteTakingWindow)
        controller.showWindow(self)

        noteTakingWindow.center()
        noteTakingWindow.orderFrontRegardless()
    }
    
    @objc
    func openLinkInDefaultBrowser(sender: NSMenuItem){
        if let event: CalendarItem = sender.representedObject as? CalendarItem {
            if event.extractedLink != "" {
                NSWorkspace.shared.open(URL(string: event.extractedLink!)!)
            }
        }
    }
    
    @objc
    func openLinkInGoogleCalendar(sender: NSMenuItem){
        if let event: CalendarItem = sender.representedObject as? CalendarItem {
            NSWorkspace.shared.open(URL(string: event.htmlLink!)!)
        }
    }

    
    @objc
    func quit(_: NSStatusBarButton) {
        NSLog("User click Quit")
        NSApplication.shared.terminate(self)
    }

}

