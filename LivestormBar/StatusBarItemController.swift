//
//  StatusBarItemController.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 14/04/2022.
//

import Foundation
import SwiftUI
import OAuth2

class StatusBarItemController: NSObject, NSMenuDelegate {
    var statusItem: NSStatusItem!
    var statusItemMenu: NSMenu!
    var menuIsOpen = false
    weak var appdelegate: AppDelegate!

    
    func enableButtonAction() {
        let button: NSStatusBarButton = statusItem.button!
        // Safe check if statusbar is created
        guard let logo = NSImage(named: NSImage.Name("logo-primary-svg")) else { return }

        let resizedLogo = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { (dstRect) -> Bool in
            logo.draw(in: dstRect)
            return true
        }
        button.image = resizedLogo
        button.target = self
        button.action = #selector(statusMenuBarAction)
        button.sendAction(on: [NSEvent.EventTypeMask.rightMouseDown, NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.leftMouseDown])
        menuIsOpen = false
    }

    
    override
    init() {
        super.init()

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        enableButtonAction()
        

        loader.requestTodayEvents(calendarID: "mathieu@livestorm.co", callback: { calendarResponse, error in
            if let error = error {
                switch error {
                case OAuth2Error.requestCancelled:
                    print("first error : \(error)")
                default:
                    print("second error : \(error)")
                }
            }
            else {
                self.statusItemMenu = NSMenu(title: "LivestormBar in Status Bar Menu")
                self.statusItemMenu.delegate = self
                self.statusItemMenu.addItem(NSMenuItem.separator())
           
                self.statusItemMenu.addItem(withTitle: "Réunions du jour",
                             action: #selector(NSText.selectAll(_:)), keyEquivalent: "")
                


                
                var eventsArray: [CalendarItem] = []
                for event in calendarResponse?.items ?? [] {
                    if event.start != nil  && event.start?.dateTime != nil {
                        eventsArray.append(event)
                    }
                }
                eventsArray.sort(by: {$0.start!.dateTime!.compare($1.start!.dateTime!) == .orderedAscending})
               
                
                for event in eventsArray {
                    self.createEventsSection(event)
                }
                
                self.createMeetingSection()
                self.createActionsSection()
         

                
            }
        })
        



    }

    @objc
    func menuWillOpen(_: NSMenu) {
        menuIsOpen = true
    }

    @objc
    func menuDidClose(_: NSMenu) {
        // remove menu when closed so we can override left click behavior
        statusItem.menu = nil
        menuIsOpen = false
    }
    func setAppDelegate(appdelegate: AppDelegate) {
        self.appdelegate = appdelegate
    }
    let loader = GoogleLoader()
    
    
    @objc
    func statusMenuBarAction(sender _: NSStatusItem) {
        NSLog("User clicked menuBar to open")
        if !menuIsOpen, statusItem.menu == nil {
            let event = NSApp.currentEvent

            // Right button click
            if event?.type == NSEvent.EventType.rightMouseUp {
                print("rightclikc")
            } else if event == nil || event?.type == NSEvent.EventType.leftMouseDown || event?.type == NSEvent.EventType.leftMouseUp {
                // show the menu as normal
                statusItem.menu = statusItemMenu
                statusItem.button?.performClick(nil) // ...and click
            }
        }
    }
    
    func createEventsSection(_ event: CalendarItem){
        
        print(event.start?.dateTime ?? "")
        
        guard let startDate = event.start?.dateTime else {
            return
        }
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm  "
        let dateToSHow = dateFormatter.string(from:startDate)
        
        let dateTitle = "\(dateToSHow) \(event.summary ?? "No title")"
        let eventMenuItem = self.statusItemMenu.addItem(
            withTitle: dateTitle,
            action: nil,
            keyEquivalent: ""
        )
        eventMenuItem.isEnabled = true
        
        eventMenuItem.submenu = NSMenu(title: "Bientôt une liste d'action diverses ici")
        
        eventMenuItem.submenu!.addItem(
            withTitle: dateTitle,
            action: #selector(AppDelegate.openPreferencesWindow),
            keyEquivalent: ""
        )
     
        eventMenuItem.submenu!.addItem(NSMenuItem.separator())
        
        eventMenuItem.submenu!.addItem(
            withTitle: "Take notes",
            action: #selector(AppDelegate.openPreferencesWindow),
            keyEquivalent: "N"
        )
      
        eventMenuItem.submenu!.addItem(
            withTitle: "Participants insights (Linkedin)",
            action: #selector(AppDelegate.openPreferencesWindow),
            keyEquivalent: "I"
        )
     
    }
    
    func createMeetingSection(){
        self.statusItemMenu.addItem(NSMenuItem.separator())
        self.statusItemMenu.addItem(withTitle: "Créer une réunion",
                               action: #selector(AppDelegate.openPreferencesWindow), keyEquivalent: "M")
    }
    
    func createActionsSection(){
        self.statusItemMenu.addItem(NSMenuItem.separator())
        self.statusItemMenu.addItem(
            withTitle: "Préférence",
            action: #selector(AppDelegate.openPreferencesWindow),
            keyEquivalent: ","
        )

        self.statusItemMenu.addItem(
            withTitle: "Quitter LivestormBar",
            action: #selector(AppDelegate.quit),
            keyEquivalent: "q"
        )
    }
}
