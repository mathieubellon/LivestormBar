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


var preferencesWindow: NSWindow! = nil
var noteTakingWindow: NSWindow! = nil

let loader = GoogleLoader()


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem?
    var statusBarItem: StatusBarItemController!
    var isPreferencesWindowOpened = false
    

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem = StatusBarItemController()
        statusBarItem.setAppDelegate(appdelegate: self)
        
        loader.oauth2.authConfig.authorizeContext = self
        NotificationCenter.default.removeObserver(self, name: OAuth2AppDidReceiveCallbackNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleRedirect(_:)), name: OAuth2AppDidReceiveCallbackNotification, object: nil)
      
        
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

    
    @IBAction func Preffy(_ sender: NSMenuItem) {
         openPreferencesWindow()
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
            NSWorkspace.shared.open(URL(string: event.extractedLink!)!)
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

