//
//  StatusBarItemController.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 14/04/2022.
//

import Foundation
import SwiftUI
import OAuth2
import Defaults


class StatusBarItemController: NSObject, NSMenuDelegate {
    var statusItem: NSStatusItem!
    var statusItemMenu: NSMenu!
    var menuIsOpen = false
    
    weak var appdelegate: AppDelegate!
    
    
    
    override
    init() {
        super.init()
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        enableButtonAction()
        self.statusItemMenu = NSMenu(title: "app_menubar")
        self.statusItemMenu.delegate = self
    }
    
    
    
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
    
    
    
    
    @objc
    func menuWillOpen(_: NSMenu) {
        menuIsOpen = true
        updateMenu()
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
    
    
    @objc
    func statusMenuBarAction(sender _: NSStatusItem) {
        if !menuIsOpen, statusItem.menu == nil {
            let event = NSApp.currentEvent
            // Right button click
            if event?.type == NSEvent.EventType.rightMouseUp {
                
            } else if event == nil || event?.type == NSEvent.EventType.leftMouseDown || event?.type == NSEvent.EventType.leftMouseUp {
                // show the menu as normal
                statusItem.menu = statusItemMenu
                statusItem.button?.performClick(nil) // ...and click
            }
        }
    }
    
    func updateMenu(){
        self.statusItemMenu.autoenablesItems = false
        self.statusItemMenu.removeAllItems()
        self.statusItemMenu.addItem(NSMenuItem.separator())
        
        self.createEventSectionHeader()
        
        if Defaults[.email] == nil {
            self.createEmptyMenu(NSLocalizedString("you_are_not_connected", comment: ""))
        }else if userCalendar.classicEvents.isEmpty{
            self.createEmptyMenu(NSLocalizedString("no_meeting", comment: ""))
        }else{
            for event in userCalendar.classicEvents {
                self.createEventMenuItem(event)
            }
        }
        
        
        
        self.createMoreActions()
        self.createActionsSection()
    }
    
    func createEventSectionHeader(){
        let title = NSLocalizedString("today", comment: "") + " (" + getDateAsString(choosenFormat: "dd MMMM") + ")"
        
        let menuHeader = self.statusItemMenu.addItem(
            withTitle: title,
            action: nil,
            keyEquivalent: ""
        )
        menuHeader.state = .off
        menuHeader.isEnabled = false
        
        let menuTitle = NSMutableAttributedString()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.9
        paragraphStyle.alignment = .left
        var styles = [NSAttributedString.Key: Any]()
        styles[NSAttributedString.Key.font] = NSFont.systemFont(ofSize: 14)
        styles[NSAttributedString.Key.foregroundColor] = NSColor.black
        menuTitle.append(NSAttributedString(string: title, attributes: styles))
        
        menuTitle.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: menuTitle.length))
        menuHeader.attributedTitle = menuTitle
    }
    
    
    
    func createEmptyMenu(_ title: String){
        let empty = self.statusItemMenu.addItem(
            withTitle: title,
            action: nil,
            keyEquivalent: ""
        )
        empty.isEnabled = false
        //        let menuTitle = NSMutableAttributedString()
        //        let paragraphStyle = NSMutableParagraphStyle()
        //        paragraphStyle.lineHeightMultiple = 0.7
        //        paragraphStyle.alignment = .center
        //        var styles = [NSAttributedString.Key: Any]()
        //        styles[NSAttributedString.Key.font] = NSFont.systemFont(ofSize: 16)
        //        styles[NSAttributedString.Key.foregroundColor] = NSColor.white
        //        menuTitle.append(NSAttributedString(string: title, attributes: styles))
        //        empty.attributedTitle = menuTitle
    }
    
    
    
    
    func createEventMenuItem(_ event: CalendarItem){
        guard let startDate = event.start.dateTime else {
            return
        }
        guard let endDate = event.end.dateTime else {
            return
        }
        let now = Date()
        var styles = [NSAttributedString.Key: Any]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm  "
        let startDateStr = dateFormatter.string(from:startDate)
        let endDateStr = dateFormatter.string(from:endDate)
        
        var dateTitle = "\(startDateStr) \(endDateStr)  \(event.summary ?? "No title")"
        
        let eventMenuItem = self.statusItemMenu.addItem(
            withTitle: dateTitle,
            action: nil,
            keyEquivalent: ""
        )
        eventMenuItem.isEnabled = true
        
        debugPrint(event.extractedLink)
        if event.extractedLink != "" {
            eventMenuItem.image = NSImage(named: "link")!
            eventMenuItem.image?.size = NSSize(width: 14, height: 14)
        }else{
            eventMenuItem.image = NSImage(named: "question")!
            eventMenuItem.image?.size = NSSize(width: 14, height: 14)
        }
        
        
        styles[NSAttributedString.Key.font] = NSFont.monospacedDigitSystemFont(ofSize:14, weight: .regular)
        eventMenuItem.state = .off
        eventMenuItem.onStateImage = nil
        
        if event.end.dateTime! < now {
            styles[NSAttributedString.Key.foregroundColor] = NSColor.disabledControlTextColor
        } else if event.start.dateTime! < now && now < event.end.dateTime! {
            styles[NSAttributedString.Key.foregroundColor] = NSColor.black
            dateTitle = dateTitle + " 🔥"
        }
        
        eventMenuItem.attributedTitle = NSAttributedString(
            string: dateTitle,
            attributes: styles
        )
        
        
        // SUBMENU
        
        eventMenuItem.submenu = NSMenu(title: "more_actions")
        
        
        if event.extractedLink != "" {
            let LSLink = eventMenuItem.submenu!.addItem(
                withTitle: NSLocalizedString("open_link_in_default_browser", comment: ""),
                action: #selector(AppDelegate.openLinkInDefaultBrowser(sender:)),
                keyEquivalent: "O"
            )
            LSLink.representedObject = event
        }else{
            eventMenuItem.submenu!.addItem(
                withTitle: NSLocalizedString("no_livestorm_meeting_link_found", comment: ""),
                action: nil,
                keyEquivalent: ""
            )
        }
        
        if event.htmlLink != nil {
            let GoogleLink = eventMenuItem.submenu!.addItem(
                withTitle: NSLocalizedString("open_event_in_google_calendar", comment: ""),
                action: #selector(AppDelegate.openLinkInGoogleCalendar(sender:)),
                keyEquivalent: "G"
            )
            GoogleLink.representedObject = event
        }
        
        
        //        let noteTaking = eventMenuItem.submenu!.addItem(
        //            withTitle: "Take notes",
        //            action: #selector(AppDelegate.openNoteTakingWindow(_:)),
        //            keyEquivalent: "N"
        //        )
        //        noteTaking.representedObject = event
        
    }
    
    func createMoreActions(){
        self.statusItemMenu.addItem(NSMenuItem.separator())
        
        let actionsMenu = self.statusItemMenu.addItem(withTitle: NSLocalizedString("more_actions", comment: ""),
                                                      action: nil, keyEquivalent: "")
        
        actionsMenu.submenu = NSMenu(title: "Actions menu")
        actionsMenu.submenu!.addItem(withTitle: NSLocalizedString("force_refresh_events", comment: ""),
                                     action: #selector(AppDelegate.updateEvents), keyEquivalent: "R")
    }
    
    
    func createActionsSection(){
        self.statusItemMenu.addItem(NSMenuItem.separator())
        self.statusItemMenu.addItem(
            withTitle: NSLocalizedString("preferences", comment: ""),
            action: #selector(AppDelegate.openPreferencesWindow),
            keyEquivalent: ","
        )
        
        self.statusItemMenu.addItem(
            withTitle: NSLocalizedString("quit_app", comment: "yo sure"),
            action: #selector(AppDelegate.quit),
            keyEquivalent: "q"
        )
    }
}
