//
//  StatusBarItemController.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 14/04/2022.
//

import Foundation
import SwiftUI


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
        
        let allitems = getTodayEvents()
        


        statusItemMenu = NSMenu(title: "LivestormBar in Status Bar Menu")
        statusItemMenu.delegate = self
        statusItemMenu.addItem(NSMenuItem.separator())
        statusItemMenu.addItem(withTitle: "Mes prochaine réunions",
                     action: #selector(NSText.selectAll(_:)), keyEquivalent: "")
        for event in allitems {
            statusItemMenu.addItem(
                withTitle: event.summary,
                action: #selector(AppDelegate.openPreferencesWindow),
                keyEquivalent: ","
            )
        }
        statusItemMenu.addItem(NSMenuItem.separator())
        statusItemMenu.addItem(withTitle: "Créer une réunion",
                               action: #selector(AppDelegate.openPreferencesWindow), keyEquivalent: "M")
        let quickActionsItem = statusItemMenu.addItem(
            withTitle: "Actions rapides",
            action: nil,
            keyEquivalent: ""
        )
        quickActionsItem.isEnabled = true
        quickActionsItem.submenu = NSMenu(title: "status_bar_quick_actions")
        let openLinkFromClipboardItem = NSMenuItem()
        openLinkFromClipboardItem.title = "status_bar_section_join_from_clipboard"
        openLinkFromClipboardItem.action = #selector(AppDelegate.openPreferencesWindow)
        openLinkFromClipboardItem.keyEquivalent = ""
        quickActionsItem.submenu!.addItem(openLinkFromClipboardItem)
        statusItemMenu.addItem(NSMenuItem.separator())
        statusItemMenu.addItem(
            withTitle: "Préférence",
            action: #selector(AppDelegate.openPreferencesWindow),
            keyEquivalent: ","
        )

        statusItemMenu.addItem(
            withTitle: "Quitter LivestormBar",
            action: #selector(AppDelegate.quit),
            keyEquivalent: "q"
        )

        enableButtonAction()
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
}
