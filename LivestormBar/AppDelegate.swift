//
//  AppDelegate.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 13/04/2022.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem?
    var popOver = NSPopover()
    var statusBarItem: StatusBarItemController!
    var preferencesWindow = NSWindowController()



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem = StatusBarItemController()
        statusBarItem.setAppDelegate(appdelegate: self)
        
        let mainStoryboard = NSStoryboard.init(name: NSStoryboard.Name("Main"), bundle: nil)
        preferencesWindow = mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("mainWindowController")) as! NSWindowController
        preferencesWindow.close()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func MenuButtonToggle(){
            //Showing Popoverr
        if let menuButton = statusItem?.button{
            self.popOver.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
        }
    }
    
    
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

            statusItemMenu = NSMenu(title: "LivestormBar in Status Bar Menu")
            statusItemMenu.delegate = self
            statusItemMenu.addItem(NSMenuItem.separator())
            statusItemMenu.addItem(withTitle: "Mes prochaine réunions",
                         action: #selector(NSText.selectAll(_:)), keyEquivalent: "")
            statusItemMenu.addItem(NSMenuItem.separator())
            statusItemMenu.addItem(withTitle: "Créer une réunion",
                         action: #selector(NSText.selectAll(_:)), keyEquivalent: "")
            statusItemMenu.addItem(withTitle: "Plus d'actions",
                         action: #selector(NSText.copy(_:)), keyEquivalent: "c")
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
    
    
    
    

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "LivestormBar")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
    
    @objc
    func openPreferencesWindow(_: NSStatusBarButton?) {
        NSLog("Open preferences window")
        preferencesWindow.showWindow(self)
        //
        
        //        if preferencesWindow != nil {
//            preferencesWindow.close()
//        }
//        preferencesWindow = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 700, height: 610),
//            styleMask: [.closable, .titled, .resizable],
//            backing: .buffered,
//            defer: false
//        )
//
//        preferencesWindow.title = "Bar Settings"
//
//
//        let storyboard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
//
//
//
//
//
//        preferencesWindow.makeKeyAndOrderFront(nil)
//        // allow the preference window can be focused automatically when opened
//        NSApplication.shared.activate(ignoringOtherApps: true)
//
//        let controller = NSWindowController(window: preferencesWindow)
//        controller.showWindow(self)
//
//        preferencesWindow.center()
//        preferencesWindow.orderFrontRegardless()
    }

    
    @objc
    func quit(_: NSStatusBarButton) {
        NSLog("User click Quit")
        NSApplication.shared.terminate(self)
    }

}

