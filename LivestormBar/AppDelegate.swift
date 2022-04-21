//
//  AppDelegate.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import Cocoa
import SwiftUI
import OAuth2


func getTodayDate() -> String{
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}







@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem?
    var statusBarItem: StatusBarItemController!
    var preferencesWindow: NSWindow! = nil
    var isPreferencesWindowOpened = false
    

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem = StatusBarItemController()
        statusBarItem.setAppDelegate(appdelegate: self)
//        let ud = UserDefaults.standard
//        ud.set("john", forKey: "name")
//        
//        print(UserDefaults.standard.value(forKey: "name"))
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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

    
    
    
    
    @objc
    func openPreferencesWindow(_: NSStatusBarButton?) {
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
    func quit(_: NSStatusBarButton) {
        NSLog("User click Quit")
        NSApplication.shared.terminate(self)
    }

}

